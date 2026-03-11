/**
 * ตรวจจับข้อมูลส่วนตัวในข้อความ (ภาษาไทย + อังกฤษ)
 * ครอบคลุมการหลบเลี่ยงเช่น ใส่เว้นวรรค จุด ขีด หรือเขียนแบบอ้อมๆ
 */

// Separator ที่คนมักใช้แทรกเพื่อหลบ regex: space . - _ * / | ,
const S = '[\\s.\\-_*\\/|,]*';

const patterns = [
    // ═══════════════════ เบอร์โทรศัพท์ ═══════════════════
    {
        name: 'เบอร์โทรศัพท์',
        regex: new RegExp(`(?:\\+?66|0)${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d`),
    },
    {
        name: 'เบอร์โทรศัพท์',
        regex: /(?:เบอร์|โทร|เบอร์โทร|โทรศัพท์|มือถือ|tel|telephone|phone|call\s*me|ติดต่อ|contact)[\s:=]*[\d\s.\-()]{8,}/i,
    },
    {
        name: 'เบอร์โทรศัพท์',
        regex: /[๐][\.\s\-]*[๐-๙][\.\s\-]*[๐-๙][\.\s\-]*[๐-๙][\.\s\-]*[๐-๙][\.\s\-]*[๐-๙][\.\s\-]*[๐-๙][\.\s\-]*[๐-๙][\.\s\-]*[๐-๙][\.\s\-]*[๐-๙]/,
    },
    {
        name: 'เบอร์โทรศัพท์',
        regex: /(?:ศูนย์|zero)[\s]?(?:แปด|สอง|หก|เก้า|eight|two|six|nine)[\s]?(?:ศูนย์|หนึ่ง|สอง|สาม|สี่|ห้า|หก|เจ็ด|แปด|เก้า|zero|one|two|three|four|five|six|seven|eight|nine)[\s-]?(?:ศูนย์|หนึ่ง|สอง|สาม|สี่|ห้า|หก|เจ็ด|แปด|เก้า|zero|one|two|three|four|five|six|seven|eight|nine)/i,
    },

    // ═══════════════════ อีเมล ═══════════════════
    {
        name: 'อีเมล',
        regex: /[a-zA-Z0-9._%+\-]+\s*[@＠]\s*[a-zA-Z0-9.\-]+\s*\.\s*[a-zA-Z]{2,}/,
    },
    {
        name: 'อีเมล',
        regex: /(?:email|อีเมล|อีเมลล์|เมล|e-mail|mail)[\s:=]*[a-zA-Z0-9._%+\-]+[\s]*(?:@|at|แอท)[\s]*[a-zA-Z0-9.\-]+/i,
    },
    {
        name: 'อีเมล',
        regex: /[a-zA-Z0-9._]+[\s]*(?:แอท|แอ็ท|at)[\s]*(?:gmail|hotmail|yahoo|outlook|live|icloud|proton)/i,
    },

    // ═══════════════════ LINE ═══════════════════
    {
        name: 'LINE ID',
        regex: /(?:line|ไลน์|ไลน|ล[า]?ย|แอดไลน์|แอ[ดด]ไลน์|add\s*line|id\s*line|line\s*id|ไอดีไลน์|id\s*ไลน์|ไลน์\s*id)[\s:@=]*[@]?[a-zA-Z0-9._\-]{3,}/i,
    },
    {
        name: 'LINE ID',
        regex: /line\.me\/[a-zA-Z0-9\/._\-]+/i,
    },
    {
        name: 'LINE ID',
        regex: /(?:แอดมา|add\s*me|เพิ่มเพื่อน|เพิ่มเป็นเพื่อน|ทักมา|ทักไลน์|ทัก\s*line|inbox\s*line|dm\s*line|แชท\s*line)[\s]*(?:ไลน์|line)?/i,
    },

    // ═══════════════════ เลขบัตรประชาชน ═══════════════════
    {
        name: 'เลขบัตรประชาชน',
        regex: new RegExp(`\\b\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d${S}\\d\\b`),
    },
    {
        name: 'เลขบัตรประชาชน',
        regex: /(?:บัตรประชาชน|เลขบัตร|id\s*card|national\s*id|citizen\s*id|เลขประจำตัว|เลข(?:ที่)?บัตร)[\s:=]*[\d\s.\-]{10,}/i,
    },

    // ═══════════════════ Facebook ═══════════════════
    {
        name: 'Facebook',
        regex: /(?:facebook|fb|เฟสบุ๊ค|เฟส|เฟซบุ๊ก|เฟซบุ๊ค|เฟสบุก|face\s*book)[\s:@/.=]*[a-zA-Z0-9._\-]{2,}/i,
    },
    {
        name: 'Facebook',
        regex: /(?:facebook|fb)\.com\/[a-zA-Z0-9._\-]+/i,
    },
    {
        name: 'Facebook',
        regex: /(?:messenger|เมสเซนเจอร์|แชทเฟส|inbox\s*(?:เฟส|fb|facebook)|ทักแชท(?:เฟส|fb))[\s:@/.=]*/i,
    },

    // ═══════════════════ Instagram ═══════════════════
    {
        name: 'Instagram',
        regex: /(?:instagram|ig|ไอจี|อินสตาแกรม|อินสตา|insta|ไอ\.?จี\.?)[\s:@=]*@?[a-zA-Z0-9._]{2,}/i,
    },
    {
        name: 'Instagram',
        regex: /instagram\.com\/[a-zA-Z0-9._]+/i,
    },

    // ═══════════════════ Twitter / X ═══════════════════
    {
        name: 'Twitter/X',
        regex: /(?:twitter|ทวิตเตอร์|ทวิต|tweet)[\s:@=]*@?[a-zA-Z0-9._]{2,}/i,
    },
    {
        name: 'Twitter/X',
        regex: /(?:twitter|x)\.com\/[a-zA-Z0-9._]+/i,
    },

    // ═══════════════════ TikTok ═══════════════════
    {
        name: 'TikTok',
        regex: /(?:tiktok|tik\s*tok|ติ๊กต๊อก|ติ๊กตอก)[\s:@=]*@?[a-zA-Z0-9._]{2,}/i,
    },
    {
        name: 'TikTok',
        regex: /tiktok\.com\/@?[a-zA-Z0-9._]+/i,
    },

    // ═══════════════════ Telegram ═══════════════════
    {
        name: 'Telegram',
        regex: /(?:telegram|เทเลแกรม|โทรเลข|tele)[\s:@=]*@?[a-zA-Z0-9._]{2,}/i,
    },
    {
        name: 'Telegram',
        regex: /t\.me\/[a-zA-Z0-9._]+/i,
    },

    // ═══════════════════ Discord ═══════════════════
    {
        name: 'Discord',
        regex: /(?:discord|ดิสคอร์ด|ดิส)[\s:@#=]*[a-zA-Z0-9._#]{2,}/i,
    },

    // ═══════════════════ WeChat ═══════════════════
    {
        name: 'WeChat',
        regex: /(?:wechat|วีแชท|weixin|微信)[\s:@=]*[a-zA-Z0-9._\-]{2,}/i,
    },

    // ═══════════════════ เลขบัญชีธนาคาร ═══════════════════
    {
        name: 'เลขบัญชีธนาคาร',
        regex: /\d{3}[\s.\-]?\d{1}[\s.\-]?\d{5}[\s.\-]?\d{1,3}/,
    },
    {
        name: 'เลขบัญชีธนาคาร',
        regex: /(?:บัญชี|เลขบัญชี|account|เลขที่บัญชี|acc(?:ount)?\s*(?:no|number)?|โอน(?:เงิน)?(?:มา)?(?:ที่)?|โอนให้|โอนเข้า|ปลายทาง)[\s:=]*[\d\s.\-]{8,}/i,
    },
    {
        name: 'เลขบัญชีธนาคาร',
        regex: /(?:กสิกร|ไทยพาณิชย์|กรุงเทพ|กรุงไทย|ทหารไทย|ttb|ออมสิน|ธ\.?ก\.?ส|กรุงศรี|ซีไอเอ็มบี|cimb|uob|ยูโอบี|ทิสโก้|tisco|เกียรตินาคิน|lh\s*bank|scb|kbank|ktb|bbl|bay|tmb|gsb|promptpay|พร้อมเพย์)[\s:=]*[\d\s.\-]{8,}/i,
    },
    {
        name: 'เลขบัญชีธนาคาร',
        regex: /(?:promptpay|prompt\s*pay|พร้อมเพย์|พร้อม\s*เพย์)[\s:=]*[\d\s.\-]{9,}/i,
    },

    // ═══════════════════ ที่อยู่ (ภาษาไทย) ═══════════════════
    {
        name: 'ที่อยู่',
        regex: /(?:ตำบล|ต\.|อำเภอ|อ\.|จังหวัด|จ\.|แขวง|เขต|หมู่บ้าน|หมู่ที่|หมู่|ม\.|ซอย|ซ\.|ถนน|ถ\.|ตรอก|บ้านเลขที่|ห้อง|ชั้น|อาคาร|คอนโด|หอพัก|แมนชั่น|รหัสไปรษณีย์|ไปรษณีย์)[\s]*[ก-๙a-zA-Z0-9\/\.\-]+/i,
    },
    {
        name: 'ที่อยู่',
        regex: /\b[1-9]\d{4}\b/,
    },
    {
        name: 'ที่อยู่',
        regex: /(?:กรุงเทพ|กทม|เชียงใหม่|เชียงราย|ขอนแก่น|นครราชสีมา|โคราช|ภูเก็ต|สงขลา|หาดใหญ่|ชลบุรี|พัทยา|เพชรบุรี|นนทบุรี|ปทุมธานี|สมุทรปราการ|อุดรธานี|ระยอง)[\s]*(?:\d|ต\.|อ\.|เขต|แขวง|ซอย|ถนน|ถ\.)/i,
    },

    // ═══════════════════ ที่อยู่ (ภาษาอังกฤษ) ═══════════════════
    {
        name: 'ที่อยู่',
        regex: /(?:address|ที่อยู่|send\s*to|deliver\s*to|ship\s*to|ส่งไป(?:ที่)?|ส่งมา(?:ที่)?|ส่งของ(?:มา)?(?:ที่)?)[\s:=]+.{10,}/i,
    },
    {
        name: 'ที่อยู่',
        regex: /(?:street|st\.|road|rd\.|avenue|ave\.|boulevard|blvd|soi|building|bldg|floor|room|apt|apartment|suite|village|moo|district|province|sub-?district)[\.\s]*[a-zA-Z0-9\s,]+/i,
    },

    // ═══════════════════ URL / ลิงก์ส่วนตัว ═══════════════════
    {
        name: 'ลิงก์/URL',
        regex: /https?:\/\/[^\s]{5,}/i,
    },
    {
        name: 'ลิงก์/URL',
        regex: /www\.[a-zA-Z0-9][a-zA-Z0-9\-]*\.[a-zA-Z]{2,}[^\s]*/i,
    },

    // ═══════════════════ เลขพาสปอร์ต ═══════════════════
    {
        name: 'เลขพาสปอร์ต',
        regex: /(?:passport|พาสปอร์ต|หนังสือเดินทาง)[\s:=]*[a-zA-Z]{1,2}[\s\-]?\d{6,8}/i,
    },

    // ═══════════════════ เลขใบขับขี่ ═══════════════════
    {
        name: 'เลขใบขับขี่',
        regex: /(?:ใบขับขี่|driver'?s?\s*licen[sc]e|driving\s*licen[sc]e|เลขใบขับขี่)[\s:=]*\d[\d\s.\-]{5,}/i,
    },
];

/**
 * Normalize ข้อความก่อนตรวจ — ลบ zero-width chars, normalize whitespace
 */
function normalizeText(text) {
    return text
        .replace(/[\u200B-\u200D\uFEFF\u00AD]/g, '') // zero-width characters
        .replace(/[\u2000-\u200A]/g, ' ');            // special spaces → normal space
}

/**
 * ตรวจจับข้อมูลส่วนตัวในข้อความ
 * @param {string} text - ข้อความที่ต้องการตรวจสอบ
 * @returns {{ detected: boolean, types: string[] }} ผลลัพธ์การตรวจจับ
 */
const detectPersonalInfo = (text) => {
    if (!text || typeof text !== 'string') {
        return { detected: false, types: [] };
    }

    const normalized = normalizeText(text);
    const detectedTypes = new Set();

    for (const pattern of patterns) {
        if (pattern.regex.test(normalized)) {
            detectedTypes.add(pattern.name);
        }
    }

    return {
        detected: detectedTypes.size > 0,
        types: [...detectedTypes],
    };
};

module.exports = { detectPersonalInfo };
