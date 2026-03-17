/**
 * รายการรหัสผ่านยอดนิยมที่ถูกใช้ใน Brute Force / Dictionary Attack
 * อ้างอิงจาก NCSC UK (National Cyber Security Centre) และ HaveIBeenPwned
 * https://www.ncsc.gov.uk/blog-post/passwords-passwords-everywhere
 *
 * Strategy:
 *  - โหลดจาก src/data/common_passwords.txt (วางไฟล์ 250K words ไว้ที่นั่น)
 *  - ถ้าไม่มีไฟล์ → fallback ใช้ hardcoded list ขนาดเล็ก
 *  - เก็บในรูป Set (hashmap) → lookup O(1) ไม่ว่าจะ 250 หรือ 250K คำ
 *  - โหลดครั้งเดียวตอน require (module cache) — ไม่อ่านไฟล์ซ้ำทุก request
 */
const fs = require('fs');
const path = require('path');

// ─── Fallback list (ใช้เมื่อไม่มีไฟล์ common_passwords.txt) ───────────────
const FALLBACK_PASSWORDS = [
  "123456", "password", "123456789", "12345678", "12345", "1234567",
  "1234567890", "qwerty", "abc123", "111111", "123123", "admin", "letmein",
  "monkey", "1234", "dragon", "master", "sunshine", "princess", "welcome",
  "shadow", "superman", "michael", "football", "baseball", "soccer", "charlie",
  "donald", "jessica", "passwd", "iloveyou", "monkey123", "batman", "trustno1",
  "hello", "freedom", "whatever", "qazwsx", "password1", "pass", "login",
  "test", "god", "ninja", "mustang", "password123", "hunter", "harley",
  "ranger", "daniel", "starwars", "klaster", "zxcvbn", "cheese", "asdfgh",
  "asdfghjkl", "zxcvbnm", "qwertyuiop", "1q2w3e4r", "1q2w3e", "qwe123",
  "654321", "987654321", "pass123", "abcdef", "abcdefg", "abc12345",
  "hello123", "welcome1", "admin123", "root", "qwerty123", "qwerty1",
  "q1w2e3r4", "1qaz2wsx", "zaq1zaq1", "zxcvbn1", "qazwsxedc", "summer",
  "winter", "spring", "autumn", "flower", "love", "angel", "baby", "family",
  "cookie", "coffee", "pizza", "pokemon", "nirvana", "purple", "orange",
  "yellow", "green", "blue", "red", "thomas", "jordan", "robert", "jennifer",
  "ashley", "password2", "killer", "internet", "computer", "mercedes",
  "000000", "111222", "121212", "696969", "1111111", "11111111", "123321",
  "1234321", "7654321", "0987654321", "0123456789", "12341234", "11223344",
  "55555555", "99999999", "10203040", "thailand", "thai1234", "1234thai",
  "bangkok", "aaaaaa", "bbbbbb", "cccccc", "aaaaaaa", "aaaaaaaa", "abcabc",
  "abc123abc", "passw0rd", "p@ssword", "p@$$w0rd", "pa$$word", "pa$$w0rd",
  "l0gin", "adm1n", "m@ster", "w3lcome", "p@ssw0rd", "summer2020", "summer2021",
  "summer2022", "summer2023", "summer2024", "winter2020", "winter2021",
  "winter2022", "winter2023", "winter2024", "spring2020", "spring2021",
  "spring2022", "spring2023", "01012000", "01011990", "31122023", "00000000",
  "changeme", "temp", "temp123", "guest", "user", "user123", "demo", "demo123",
  "test123", "testing", "test1234", "default", "system", "oracle", "postgres",
  "mysql", "admin@123", "admin1234", "administrator", "starwars1", "superman1",
  "batman123", "ironman", "avengers", "magic", "matrix", "iloveyou1",
  "asd123", "qwe456", "abc456", "xyz123", "pass1234", "pass12345",
  "mypassword", "mypass", "mypass123",
];

// ─── โหลด word list เข้า Set (hashmap) ครั้งเดียวตอน module load ───────────
function loadPasswordSet() {
  const filePath = path.join(__dirname, '../data/common_passwords.txt');
  try {
    const content = fs.readFileSync(filePath, 'utf-8');
    const words = content
      .split('\n')
      .map(line => line.trim().toLowerCase())
      .filter(line => line.length > 0 && !line.startsWith('#'));
    const set = new Set(words);
    console.log(`[commonPasswords] Loaded ${set.size.toLocaleString()} passwords from file`);
    return set;
  } catch {
    // ไม่มีไฟล์ — ใช้ fallback list
    const set = new Set(FALLBACK_PASSWORDS.map(w => w.toLowerCase()));
    console.warn(`[commonPasswords] common_passwords.txt not found — using fallback list (${set.size} entries)`);
    console.warn(`[commonPasswords] Place your word list at: src/data/common_passwords.txt`);
    return set;
  }
}

// Module-level cache — โหลดครั้งเดียว ไม่อ่านไฟล์ซ้ำทุก request
const COMMON_PASSWORDS = loadPasswordSet();

/**
 * ตรวจสอบว่ารหัสผ่านอยู่ใน word list ที่ใช้ Brute Force หรือไม่ (case-insensitive)
 * - Exact match: ทุกคำใน Set — O(1) lookup
 * - Substring match: เฉพาะคำที่ยาว >= 5 ตัว **และรหัสผ่านไม่ใช่ passphrase** (ไม่มี - คั่น)
 *   เหตุผล: passphrase เช่น summer-coffee-pizza มีความปลอดภัยจาก combination entropy
 *   ไม่ใช่ความหายากของแต่ละคำ การ block substring บน passphrase จะทำให้ระบบสุ่มใช้ไม่ได้
 * @param {string} password
 * @returns {boolean}
 */
function isCommonPassword(password) {
  if (!password) return false;
  const lower = password.toLowerCase();
  // Exact match ก่อน (O(1))
  if (COMMON_PASSWORDS.has(lower)) return true;
  // Substring match: ข้ามถ้าเป็น passphrase (มี - คั่นคำ) เพราะความปลอดภัยมาจาก combination
  const isPassphrase = lower.includes('-');
  if (!isPassphrase) {
    for (const word of COMMON_PASSWORDS) {
      if (word.length >= 5 && lower.includes(word)) return true;
    }
  }
  return false;
}

module.exports = { isCommonPassword, COMMON_PASSWORDS };
