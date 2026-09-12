# PashuDrishti AI Deployment Package — V1 (JavaScript Fetch)

## Architecture

The existing application backend can use:

- **ResNet-50:** Roboflow hosted Workflow called through native JavaScript `fetch`
- **XGBoost:** the included trained symptom model, served by the backend's model runtime
- **Fusion:** JavaScript software layer
- **Knowledge Base:** your existing veterinary knowledge-base/report layer

```text
Existing Backend
      |
      +---- fetch ----> Roboflow Cloud ResNet
      |
      +---------------> XGBoost
      |
      +----> Fusion
                |
                +----> Knowledge Base
                         |
                         +----> Final Report
```

## Roboflow configuration

- Workspace: `abhinav-bharadwaj`
- Workflow: `pashu-drishti-vpashu-drishti-1-resnet50-t1-logic`
- Hosted endpoint base: `https://serverless.roboflow.com`

The integration uses:

```text
POST /abhinav-bharadwaj/workflows/pashu-drishti-vpashu-drishti-1-resnet50-t1-logic
```

with the image passed as a URL:

```json
{
  "inputs": {
    "image": {
      "type": "url",
      "value": "IMAGE_URL"
    }
  }
}
```

## Security

The API key MUST remain server-side.

Set:

```text
ROBOFLOW_API_KEY=...
```

in your backend environment/secret manager.

Do not put it in frontend JavaScript, do not commit it to Git, and do not expose it to users.

The API key that was pasted into the conversation should be treated as exposed. **Revoke/rotate that key in Roboflow and use the new key in your server environment.**

## JavaScript integration

Use:

`integration/pashudrishti_ai.js`

The main ResNet function is:

```js
const result = await runResNet(imageUrl);
```

It uses native `fetch`, so no Roboflow Python SDK is required.

Node.js 18+ has native `fetch`.

## Important: first-response mapping

The exact JSON returned by the Roboflow Workflow must be inspected once.

If its output is not already represented as:

```json
{
  "class": "Lumpy",
  "confidence": 0.92
}
```

or an equivalent nested structure, modify only:

`extractResNetPredictions()`

The function is intentionally isolated for this purpose.

## XGBoost

The trained XGBoost artifacts are in:

`xgboost_model/`

- `pashudrishti_xgboost.json`
- `label_encoder.pkl`
- `feature_config.json`
- `disease_labels.json`

The XGBoost model was trained once on the current knowledge-derived symptom dataset.

The JavaScript layer accepts XGBoost predictions in this form:

```js
[
  { label: "Lumpy", confidence: 0.81 },
  { label: "Mastitis", confidence: 0.07 }
]
```

The actual XGBoost runtime can remain in the team's existing Python service if the backend already uses Python. The ResNet side does not require Python.

## Fusion

When both modalities exist, the reference implementation uses:

- image weight: `0.60`
- symptom weight: `0.40`

These are software defaults, not clinically validated weights.

If only image is supplied, image predictions are returned.

If only symptoms are supplied, symptom predictions are returned.

If both are supplied, the two ranked lists are combined.

## API contract

`integration_contract.json` describes the model inputs/outputs.

## Model limitation

The XGBoost training data is knowledge-derived rather than a database of independently confirmed clinical cases. It is therefore an AI-assistance component for the testing application and must not be represented as clinically validated diagnostic software.

