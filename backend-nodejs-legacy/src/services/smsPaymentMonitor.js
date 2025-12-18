const crypto = require('crypto');

class SMSPaymentMonitor {
  // Generate unique reference for each deposit request
  generatePaymentReference(userId, amount) {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000);
    return `PAY${userId}${timestamp}${random}`;
  }

  // Parse bKash SMS format
  parseBkashSMS(smsBody) {
    // Example formats:
    // "You have received Tk 500.00 from 01712345678 on 15/12/2024. TrxID: ABC123XYZ"
    // "Cash In Tk 500 from 01712345678. TrxID ABC123XYZ"
    const amountMatch = smsBody.match(/Tk\s*([\d,]+\.?\d*)/i);
    const senderMatch = smsBody.match(/from\s*(\d{11})/i);
    const trxIdMatch = smsBody.match(/TrxID[:\s]*([A-Z0-9]+)/i);
    
    return {
      amount: amountMatch ? parseFloat(amountMatch[1].replace(',', '')) : null,
      sender: senderMatch ? senderMatch[1] : null,
      trxId: trxIdMatch ? trxIdMatch[1] : null,
      method: 'bkash'
    };
  }

  // Parse Nagad SMS format
  parseNagadSMS(smsBody) {
    // Example: "Cash In Tk 500.00 from 01712345678. TxnID: ABC123. Balance: Tk 1000"
    const amountMatch = smsBody.match(/Tk\s*([\d,]+\.?\d*)/i);
    const senderMatch = smsBody.match(/from\s*(\d{11})/i);
    const trxIdMatch = smsBody.match(/TxnID[:\s]*([A-Z0-9]+)/i);
    
    return {
      amount: amountMatch ? parseFloat(amountMatch[1].replace(',', '')) : null,
      sender: senderMatch ? senderMatch[1] : null,
      trxId: trxIdMatch ? trxIdMatch[1] : null,
      method: 'nagad'
    };
  }

  // Parse Rocket SMS format
  parseRocketSMS(smsBody) {
    const amountMatch = smsBody.match(/Tk\s*([\d,]+\.?\d*)/i);
    const senderMatch = smsBody.match(/from\s*(\d{11})/i);
    const trxIdMatch = smsBody.match(/Trx[:\s]*([A-Z0-9]+)/i);
    
    return {
      amount: amountMatch ? parseFloat(amountMatch[1].replace(',', '')) : null,
      sender: senderMatch ? senderMatch[1] : null,
      trxId: trxIdMatch ? trxIdMatch[1] : null,
      method: 'rocket'
    };
  }

  // Determine payment method from SMS sender
  detectPaymentMethod(smsSender) {
    const sender = smsSender.toLowerCase();
    
    if (sender.includes('bkash') || sender.includes('16247')) {
      return 'bkash';
    } else if (sender.includes('nagad') || sender.includes('16167')) {
      return 'nagad';
    } else if (sender.includes('rocket') || sender.includes('16216')) {
      return 'rocket';
    }
    
    return 'unknown';
  }

  // Parse SMS based on detected method
  parseSMS(method, smsBody) {
    switch (method) {
      case 'bkash':
        return this.parseBkashSMS(smsBody);
      case 'nagad':
        return this.parseNagadSMS(smsBody);
      case 'rocket':
        return this.parseRocketSMS(smsBody);
      default:
        return null;
    }
  }
}

module.exports = new SMSPaymentMonitor();
