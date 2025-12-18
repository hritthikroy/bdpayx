const twilio = require('twilio');

class WhatsAppService {
  constructor() {
    this.client = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );
    this.whatsappNumber = process.env.TWILIO_WHATSAPP_NUMBER || 'whatsapp:+14155238886';
    
    // Store OTPs in memory (use Redis in production)
    this.otpStore = new Map();
  }

  // Generate 6-digit OTP
  generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  // Send OTP via WhatsApp
  async sendOTP(phoneNumber) {
    try {
      const otp = this.generateOTP();
      
      // Store OTP with 5 minute expiry
      this.otpStore.set(phoneNumber, {
        otp,
        expiresAt: Date.now() + 5 * 60 * 1000, // 5 minutes
        attempts: 0
      });

      // Format phone number for WhatsApp
      const formattedPhone = phoneNumber.startsWith('+') 
        ? `whatsapp:${phoneNumber}` 
        : `whatsapp:+${phoneNumber}`;

      // Send WhatsApp message
      const message = await this.client.messages.create({
        from: this.whatsappNumber,
        to: formattedPhone,
        body: `🔐 Your BDPayX verification code is: ${otp}\n\nValid for 5 minutes.\n\nDo not share this code with anyone.`
      });

      console.log(`WhatsApp OTP sent to ${phoneNumber}: ${message.sid}`);
      
      return {
        success: true,
        message: 'OTP sent successfully',
        sid: message.sid
      };
    } catch (error) {
      console.error('WhatsApp OTP error:', error);
      throw new Error('Failed to send OTP. Please try again.');
    }
  }

  // Verify OTP
  verifyOTP(phoneNumber, otp) {
    const stored = this.otpStore.get(phoneNumber);

    if (!stored) {
      return {
        success: false,
        message: 'OTP not found. Please request a new one.'
      };
    }

    // Check expiry
    if (Date.now() > stored.expiresAt) {
      this.otpStore.delete(phoneNumber);
      return {
        success: false,
        message: 'OTP expired. Please request a new one.'
      };
    }

    // Check attempts
    if (stored.attempts >= 3) {
      this.otpStore.delete(phoneNumber);
      return {
        success: false,
        message: 'Too many attempts. Please request a new OTP.'
      };
    }

    // Verify OTP
    if (stored.otp === otp) {
      this.otpStore.delete(phoneNumber);
      return {
        success: true,
        message: 'OTP verified successfully'
      };
    }

    // Increment attempts
    stored.attempts++;
    this.otpStore.set(phoneNumber, stored);

    return {
      success: false,
      message: `Invalid OTP. ${3 - stored.attempts} attempts remaining.`
    };
  }

  // Clean up expired OTPs (run periodically)
  cleanupExpiredOTPs() {
    const now = Date.now();
    for (const [phone, data] of this.otpStore.entries()) {
      if (now > data.expiresAt) {
        this.otpStore.delete(phone);
      }
    }
  }
}

// Cleanup expired OTPs every minute
const whatsappService = new WhatsAppService();
setInterval(() => whatsappService.cleanupExpiredOTPs(), 60000);

module.exports = whatsappService;
