/**
 * รายการรหัสผ่านยอดนิยมที่ถูกใช้ใน Brute Force / Dictionary Attack
 * อ้างอิงจาก NCSC UK (National Cyber Security Centre) และ HaveIBeenPwned
 * https://www.ncsc.gov.uk/blog-post/passwords-passwords-everywhere
 *
 * ใช้สำหรับตรวจสอบว่ารหัสผ่านที่ผู้ใช้ตั้งนั้นอยู่ใน word list ที่ใช้โจมตีหรือไม่
 */
const COMMON_PASSWORDS = new Set([
  // Top 10 most used
  "123456", "password", "123456789", "12345678", "12345", "1234567",
  "1234567890", "qwerty", "abc123", "111111",

  // Top 11-50
  "123123", "admin", "letmein", "monkey", "1234", "dragon", "master",
  "sunshine", "princess", "welcome", "shadow", "superman", "michael",
  "football", "baseball", "soccer", "charlie", "donald", "jessica",
  "passwd", "iloveyou", "monkey123", "batman", "trustno1", "hello",
  "freedom", "whatever", "qazwsx", "password1", "pass",

  // Top 51-100
  "login", "test", "god", "ninja", "mustang", "password123", "hunter",
  "harley", "ranger", "daniel", "starwars", "klaster", "zxcvbn",
  "cheese", "asdfgh", "asdfghjkl", "zxcvbnm", "qwertyuiop", "1q2w3e4r",
  "1q2w3e", "qwe123", "654321", "987654321", "pass123", "abcdef",
  "abcdefg", "abc12345", "hello123", "welcome1", "admin123", "root",

  // Common keyboard walks
  "qwerty123", "qwerty1", "q1w2e3r4", "1qaz2wsx", "!qaz2wsx",
  "zaq1zaq1", "zxcvbn1", "qazwsxedc", "1qazxsw2", "2wsxcde3",

  // Common words / phrases
  "summer", "winter", "spring", "autumn", "flower", "love", "angel",
  "baby", "family", "cheese", "cookie", "coffee", "pizza", "pokemon",
  "nirvana", "purple", "orange", "yellow", "green", "blue", "red",

  // Names frequently used as passwords
  "michael", "thomas", "jordan", "robert", "jennifer", "jessica",
  "ashley", "password2", "killer", "internet", "computer", "mercedes",

  // Number sequences
  "000000", "111222", "121212", "696969", "1111111", "11111111",
  "123321", "1234321", "7654321", "0987654321", "0123456789",
  "12341234", "11223344", "55555555", "99999999", "10203040",

  // Common Thai-related passwords
  "thailand", "thai1234", "1234thai", "bangkok", "สวัสดี", "123456789",

  // Patterns
  "aaaaaa", "bbbbbb", "cccccc", "aaaaaaa", "aaaaaaaa",
  "abcabc", "abc123abc", "password!", "p@ssword", "p@ss123",
  "p@$$w0rd", "passw0rd", "pa$$word", "pa$$w0rd",

  // Leet speak common variants
  "p@ssw0rd", "l0gin", "adm1n", "m@ster", "w3lcome",

  // Season + year (covers recent years frequently used)
  "summer2020", "summer2021", "summer2022", "summer2023", "summer2024",
  "winter2020", "winter2021", "winter2022", "winter2023", "winter2024",
  "spring2020", "spring2021", "spring2022", "spring2023",

  // Common date-based
  "01012000", "01011990", "31122023", "12345678901", "00000000",

  // Service-specific common
  "changeme", "temp", "temp123", "guest", "user", "user123",
  "demo", "demo123", "test123", "testing", "test1234",
  "default", "system", "oracle", "postgres", "mysql",
  "admin@123", "admin1234", "Admin123", "administrator",

  // Movie / pop culture
  "starwars1", "superman1", "batman123", "Spiderman", "ironman",
  "avengers", "magic", "matrix", "iloveyou1",

  // Repeated chars + number
  "asd123", "qwe456", "abc456", "xyz123", "pass1234",
  "pass12345", "mypassword", "mypass", "mypass123",
]);

/**
 * ตรวจสอบว่ารหัสผ่านที่กรอกอยู่ใน word list ที่ใช้ Brute Force หรือไม่
 * - Exact match: ตรวจทุกคำใน list
 * - Substring match: ตรวจคำที่ยาว >= 5 ตัวอักษร
 *   (ป้องกัน aaaaaa x2, aaaaaaaaaaaa ฯลฯ)
 * @param {string} password
 * @returns {boolean} คืนค่า true ถ้าอยู่ใน list หรือ มีคำใน list (อันตราย)
 */
export function isCommonPassword(password) {
  if (!password) return false;
  const lower = password.toLowerCase();
  for (const word of COMMON_PASSWORDS) {
    // exact match ทุกคำ หรือ substring match เฉพาะคำที่ยาว >= 5 ตัว
    if (lower === word) return true;
    if (word.length >= 5 && lower.includes(word)) return true;
  }
  return false;
}

export default COMMON_PASSWORDS;
