/**
 * PashuDrishti AI integration
 *
 * ResNet:
 *   Roboflow hosted Workflow via native JavaScript fetch
 *
 * XGBoost:
 *   Keep the trained XGBoost model in the existing backend/model service.
 *
 * IMPORTANT:
 *   Never put ROBOFLOW_API_KEY in frontend/browser code.
 *   Keep it server-side as an environment secret.
 */

const ROBOFLOW_API_URL =
  process.env.ROBOFLOW_API_URL ||
  "https://serverless.roboflow.com";

const ROBOFLOW_WORKSPACE =
  process.env.ROBOFLOW_WORKSPACE ||
  "abhinav-bharadwaj";

const ROBOFLOW_WORKFLOW =
  process.env.ROBOFLOW_WORKFLOW ||
  "pashu-drishti-vpashu-drishti-1-resnet50-t1-logic";

function roboflowEndpoint() {
  return `${ROBOFLOW_API_URL}/${ROBOFLOW_WORKSPACE}/workflows/${ROBOFLOW_WORKFLOW}`;
}

/**
 * Call the trained ResNet workflow.
 *
 * imageUrl must be a URL accessible to Roboflow.
 */
export async function runResNet(imageUrl) {
  const apiKey = process.env.ROBOFLOW_API_KEY?.replace(/^Bearer\s+/i, "").trim();

  if (!apiKey) {
    throw new Error("ROBOFLOW_API_KEY is not configured.");
  }

  if (!imageUrl) {
    throw new Error("imageUrl is required.");
  }

  const response = await fetch(roboflowEndpoint(), {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      api_key: apiKey,
      inputs: {
        image: {
          type: "url",
          value: imageUrl,
        },
      },
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(
      `Roboflow request failed (${response.status}): ${errorText}`
    );
  }

  return await response.json();
}

/**
 * Extract predictions from the actual Workflow response.
 *
 * IMPORTANT:
 * Run one real request and inspect the returned JSON.
 * If your Workflow uses a different output structure, modify ONLY this
 * function. Do not change the model or fusion logic.
 */
export function extractResNetPredictions(result) {
  const candidates = [];

  function walk(value) {
    if (!value) return;

    if (Array.isArray(value)) {
      for (const item of value) walk(item);
      return;
    }

    if (typeof value === "object") {
      const label =
        value.class ??
        value.label ??
        value.name;

      const confidence =
        value.confidence ??
        value.score ??
        value.probability;

      if (label !== undefined && confidence !== undefined) {
        const score = Number(confidence);

        if (Number.isFinite(score)) {
          candidates.push({
            label: String(label),
            confidence: score,
          });
        }
      }

      for (const child of Object.values(value)) {
        walk(child);
      }
    }
  }

  walk(result);

  // Keep the highest score for duplicate labels.
  const best = new Map();

  for (const prediction of candidates) {
    const previous = best.get(prediction.label) ?? 0;
    best.set(
      prediction.label,
      Math.max(previous, prediction.confidence)
    );
  }

  return [...best.entries()]
    .map(([label, confidence]) => ({
      label,
      confidence,
    }))
    .sort((a, b) => b.confidence - a.confidence);
}

/**
 * Software-level fusion.
 *
 * These weights are application defaults, NOT clinically validated weights.
 */
export function fusePredictions({
  imagePredictions = [],
  symptomPredictions = [],
  imageWeight = 0.60,
  symptomWeight = 0.40,
}) {
  if (!imagePredictions.length) {
    return [...symptomPredictions].sort(
      (a, b) => b.confidence - a.confidence
    );
  }

  if (!symptomPredictions.length) {
    return [...imagePredictions].sort(
      (a, b) => b.confidence - a.confidence
    );
  }

  const scores = new Map();

  for (const prediction of imagePredictions) {
    scores.set(
      prediction.label,
      (scores.get(prediction.label) ?? 0) +
        imageWeight * prediction.confidence
    );
  }

  for (const prediction of symptomPredictions) {
    scores.set(
      prediction.label,
      (scores.get(prediction.label) ?? 0) +
        symptomWeight * prediction.confidence
    );
  }

  const total =
    [...scores.values()].reduce((sum, value) => sum + value, 0) || 1;

  return [...scores.entries()]
    .map(([label, score]) => ({
      label,
      confidence: score / total,
    }))
    .sort((a, b) => b.confidence - a.confidence);
}

/**
 * Example application flow.
 *
 * XGBoost prediction should be supplied by your existing backend/model
 * service because this package contains the trained XGBoost artifacts but
 * does not assume a particular Node.js XGBoost runtime.
 */
export async function predict({
  animal,
  symptoms = [],
  imageUrl = null,
  symptomPredictions = [],
}) {
  const rawResNetResult = imageUrl
    ? await runResNet(imageUrl)
    : null;

  const imagePredictions = rawResNetResult
    ? extractResNetPredictions(rawResNetResult)
    : [];

  const fusedPredictions = fusePredictions({
    imagePredictions,
    symptomPredictions,
  });

  return {
    animal,
    image_predictions: imagePredictions,
    symptom_predictions: symptomPredictions,
    fused_predictions: fusedPredictions.slice(0, 10),
    raw_resnet_result: rawResNetResult,
  };
}
