import nodemailer from 'nodemailer';

// Create email transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});

export const sendPasswordResetEmail = async (email, resetToken) => {
  try {
    const resetLink = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password/${resetToken}`;
    
    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Pashudrishti - Password Reset Request',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(to right, #3b82f6, #0ea5e9); padding: 20px; text-align: center; border-radius: 10px;">
            <h1 style="color: white; margin: 0;">Pashudrishti</h1>
            <p style="color: #e0e7ff; margin: 0;">AI-Powered Animal Disease Detection</p>
          </div>
          
          <div style="padding: 20px; background-color: #f8f9fa;">
            <h2 style="color: #1e40af;">Password Reset Request</h2>
            
            <p style="color: #333;">Hello,</p>
            <p style="color: #555;">We received a request to reset the password for your Pashudrishti account. If you did not make this request, you can safely ignore this email.</p>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="${resetLink}" style="display: inline-block; background-color: #3b82f6; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: bold;">
                Reset Password
              </a>
            </div>
            
            <p style="color: #666; font-size: 12px; margin-top: 20px;">
              Or copy this link: <br>
              <span style="word-break: break-all; color: #0ea5e9;">${resetLink}</span>
            </p>
            
            <p style="color: #999; font-size: 12px; margin-top: 20px;">
              This link will expire in 1 hour. If you need further assistance, please contact our support team.
            </p>
          </div>
          
          <div style="text-align: center; padding: 20px; color: #999; font-size: 12px; border-top: 1px solid #ddd;">
            <p>© 2025 Pashudrishti. All rights reserved.</p>
          </div>
        </div>
      `
    };

    await transporter.sendMail(mailOptions);
    console.log(`Password reset email sent to ${email}`);
    return true;
  } catch (error) {
    console.error('Error sending email:', error.message);
    throw error;
  }
};
