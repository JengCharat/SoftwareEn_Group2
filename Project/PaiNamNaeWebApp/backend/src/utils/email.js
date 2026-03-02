const nodemailer = require('nodemailer');

/**
 * สร้าง SMTP transporter จาก ENV
 * 
 * ตัวแปรที่ต้องตั้ง (.env):
 *   SMTP_HOST      — เช่น smtp.gmail.com
 *   SMTP_PORT      — เช่น 587
 *   SMTP_SECURE    — true (465) | false (587+STARTTLS) — default: false
 *   SMTP_USER      — email ผู้ส่ง
 *   SMTP_PASS      — app password / password
 *   SMTP_FROM_NAME — ชื่อผู้ส่ง (default: ไปนำแหน่)
 */
const createTransporter = () => {
    const host = process.env.SMTP_HOST;
    const port = parseInt(process.env.SMTP_PORT || '587', 10);
    const secure = process.env.SMTP_SECURE === 'true';
    const user = process.env.SMTP_USER;
    const pass = process.env.SMTP_PASS;

    if (!host || !user || !pass) {
        return null; // ไม่ได้ตั้งค่า → ข้ามการส่งอีเมล
    }

    return nodemailer.createTransport({
        host,
        port,
        secure,
        auth: { user, pass },
    });
};

let _transporter = undefined; // lazy singleton

const getTransporter = () => {
    if (_transporter === undefined) {
        _transporter = createTransporter();
    }
    return _transporter;
};

/**
 * ส่งอีเมล — ถ้าไม่ได้ตั้งค่า SMTP จะ log แล้ว return โดยไม่ throw
 * @param {{ to: string, subject: string, text?: string, html?: string }} options
 * @returns {Promise<{accepted: string[]} | null>}
 */
const sendEmail = async ({ to, subject, text, html }) => {
    const transporter = getTransporter();
    if (!transporter) {
        console.warn('[Email] SMTP not configured — skipping email to', to);
        return null;
    }

    const fromName = process.env.SMTP_FROM_NAME || 'ไปนำแหน่';
    const from = `"${fromName}" <${process.env.SMTP_USER}>`;

    try {
        const info = await transporter.sendMail({ from, to, subject, text, html });
        console.log('[Email] Sent to', to, '— messageId:', info.messageId);
        return info;
    } catch (err) {
        console.error('[Email] Failed to send to', to, err.message);
        // ไม่ throw — อีเมลเป็น best-effort ไม่ควรทำให้ API พัง
        return null;
    }
};

module.exports = { sendEmail };
