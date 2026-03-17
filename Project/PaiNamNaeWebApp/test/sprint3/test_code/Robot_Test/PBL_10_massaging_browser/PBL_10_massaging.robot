*** Settings ***
Documentation     Test Cases for Chat Feature - Task 10
...               Story: As a driver, I want to send a message to a passenger
...               without revealing too much personal information so that I can
...               communicate with them in a saver manner.
...
...               รวม 3 ไฟล์:
...               - test_chat_driver.robot    (CHAT01–CHAT04)
...               - test_chat_passenger.robot (CHAT07–CHAT09)
...               - test_chat_privacy.robot   (CHAT10–CHAT29)
...
...               Privacy Warning Behavior (จาก UI จริง):
...               - Warning แสดงใต้ช่องพิมพ์แบบ real-time ขณะพิมพ์ (ก่อนกด submit)
...               - ข้อความ warning: "ตรวจพบข้อมูลที่อาจเป็น[ประเภท]ในข้อความ
...                 กรุณาระวังการเปิดเผยข้อมูลส่วนตัว"
...               - ระบบยังคงแสดง warning แต่อนุญาตให้ส่งข้อความได้
...                 (warn-only — ไม่ได้ block การส่ง)
Resource          resource.robot

*** Variables ***
${BOOKING ID}         cmllrfr8e0002srkctyiklcp5
${CHAT URL}           https://csse0269.cpkku.com/chat/${BOOKING ID}
${OTHER USER}         otheruser
${OTHER PASS}         otheruser12345678
${CHAT TEXTAREA}      xpath://textarea[@placeholder='พิมพ์ข้อความ...']
${CHAT SUBMIT BTN}    xpath://button[@type='submit']
# Warning banner ที่แสดงใต้ช่องพิมพ์ขณะพิมพ์ข้อมูลส่วนตัว (จาก UI จริง)
${PRIVACY WARNING}    xpath://*[contains(text(),'ตรวจพบข้อมูลที่อาจเป็น')]


*** Test Cases ***

# ═══════════════════════════════════════════════════════
# ── Driver Side ──
# ═══════════════════════════════════════════════════════

CHAT01 - Driver Opens Chat And Sees Only Role And Profile Picture
    [Documentation]    เปิดหน้าแชทในฐานะคนขับ แสดงเฉพาะ "คนขับ" และ "ผู้โดยสาร"
    ...                ไม่แสดงชื่อจริงของทั้งสองฝ่าย
    Login As Driver
    Sleep    2s
    Go To My Route Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้โดยสาร']
    Sleep    2s
    Page Should Contain Element    xpath://div[contains(@class,'text-gray-500') and normalize-space()='ผู้โดยสาร']
    Page Should Not Contain Element    xpath://div[contains(@class,'text-gray-500') and not(normalize-space()='ผู้โดยสาร')]
    Page Should Contain    ข้อความถูกส่งอย่างปลอดภัย โดยไม่เปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT02 - Driver Sends Message And It Appears Immediately
    [Documentation]    Driver พิมพ์และส่งข้อความ → ข้อความแสดงผลในหน้าแชทของตัวเองทันที
    Login As Driver
    Sleep    2s
    Go To My Route Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้โดยสาร']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    ทดสอบ CHAT02 สวัสดีครับ
    Wait Until Element Is Enabled    ${CHAT SUBMIT BTN}    timeout=5s
    Click Button    ${CHAT SUBMIT BTN}
    Sleep    1s
    Page Should Contain    ทดสอบ CHAT02 สวัสดีครับ
    [Teardown]    Close Browser Session

CHAT03 - Driver Sends Message And Passenger Receives Within 5 Seconds
    [Documentation]    Driver ส่งข้อความ → Passenger ได้รับข้อความภายใน 5 วินาที (Polling)
    # Step 1: Driver เปิด browser แรก แล้วส่งข้อความ
    Login As Driver
    Sleep    2s
    Go To My Route Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้โดยสาร']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    ทดสอบ CHAT03 สวัสดีครับ
    Wait Until Element Is Enabled    ${CHAT SUBMIT BTN}    timeout=5s
    Click Button    ${CHAT SUBMIT BTN}
    Sleep    1s
    # Step 2: Passenger เปิด browser ใหม่ แล้วเข้าหน้าแชทเดียวกัน
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    5s
    Page Should Contain    ทดสอบ CHAT03 สวัสดีครับ
    [Teardown]    Close All Browsers

CHAT04 - Unauthorized User Cannot Access Chat Room
    [Documentation]    User ที่ไม่ได้อยู่ใน Booking พยายามเข้าหน้าแชท → ได้รับ 404
    Open Browser    https://csse0269.cpkku.com/login    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    ${DELAY}
    Input Username    ${OTHER USER}
    Input Password    ${OTHER PASS}
    Submit Login
    Sleep    2s
    Go To    ${CHAT URL}
    Sleep    2s
    Page Should Contain    404
    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# ── Passenger Side ──
# ═══════════════════════════════════════════════════════

CHAT07 - Passenger Opens Chat And Sees Only Role And Profile Picture
    [Documentation]    Passenger เปิดหน้าแชท → แสดงเฉพาะ "คนขับ"
    ...                ไม่แสดงชื่อจริง
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Page Should Contain Element    xpath://div[contains(@class,'text-gray-500') and normalize-space()='คนขับ']
    Page Should Not Contain Element    xpath://div[contains(@class,'text-gray-500') and not(normalize-space()='คนขับ')]
    Page Should Contain    ข้อความถูกส่งอย่างปลอดภัย โดยไม่เปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT08 - Passenger Sends Message And Driver Receives Within 5 Seconds
    [Documentation]    Passenger ส่งข้อความ → Driver ได้รับข้อความภายใน 5 วินาที (Polling)
    # Step 1: Passenger ส่งข้อความก่อน
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    ทดสอบ CHAT09 สวัสดีค่ะ
    Wait Until Element Is Enabled    ${CHAT SUBMIT BTN}    timeout=5s
    Click Button    ${CHAT SUBMIT BTN}
    Sleep    1s
    # Step 2: Driver เปิด browser ใหม่ แล้วเข้าหน้าแชทเดียวกัน
    Login As Driver
    Sleep    2s
    Go To My Route Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้โดยสาร']
    Sleep    2s
    # Step 3: รอ Polling ไม่เกิน 5 วิ แล้วเช็คว่าเห็นข้อความสีเทาจากฝั่ง Passenger
    Sleep    5s
    Page Should Contain    ทดสอบ CHAT09 สวัสดีค่ะ
    [Teardown]    Close All Browsers

CHAT09 - Passenger Sends Message And It Appears Immediately
    [Documentation]    Passenger พิมพ์และส่งข้อความ → ข้อความแสดงผลในหน้าแชทของตัวเองทันที
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    ทดสอบ CHAT10 สวัสดีค่ะ
    Wait Until Element Is Enabled    ${CHAT SUBMIT BTN}    timeout=5s
    Click Button    ${CHAT SUBMIT BTN}
    Sleep    1s
    Page Should Contain    ทดสอบ CHAT10 สวัสดีค่ะ
    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# ── Privacy Detection — เบอร์โทรศัพท์ ──
# ═══════════════════════════════════════════════════════

CHAT10 - Warning Appears When Types Phone Number
    [Documentation]     พิมพ์เบอร์โทรรูปแบบมาตรฐาน "0812345678" ในช่องข้อความ
    ...                ผลที่คาดหวัง: warning แสดงใต้ช่องพิมพ์ทันทีขณะพิมพ์
    ...                "ตรวจพบข้อมูลที่อาจเป็นเบอร์โทรศัพท์...กรุณาระวังการเปิดเผยข้อมูลส่วนตัว"
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    ติดต่อผมได้เลยครับ 0812345678
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นเบอร์โทรศัพท์, เลขบัญชีธนาคารในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT11 - Warning Appears When Types Phone Number With Separators
    [Documentation]     พิมพ์เบอร์โทรที่มีขีดคั่น "081-234-5678"
    ...                (หลบเลี่ยง regex ด้วย separator — ระบบใช้ pattern S = [\s.\-_*\/|,]*)
    ...                ผลที่คาดหวัง: warning ยังปรากฏ — ระบบ detect evasion ได้
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    081-234-5678
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นเบอร์โทรศัพท์ในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT12 - Detect Phone With Separator
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    0 8 1-2 3 4-5 6 7 8
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นเบอร์โทรศัพท์ในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT13 - Detect Phone With Keyword
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    เบอร์ 0812345678
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นเบอร์โทรศัพท์, เลขบัญชีธนาคารในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session    

CHAT14 - Detect Phone Thai Number
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    ๐๘๑๒๓๔๕๖๗๘
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นเบอร์โทรศัพท์ในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT15 - Detect Phone Word Form
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    zero eight one two three
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นเบอร์โทรศัพท์, Instagramในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session   
# ═══════════════════════════════════════════════════════
# ── Privacy Detection — อีเมล ──
# ═══════════════════════════════════════════════════════

CHAT16 - Warning Appears When Types Email Address
    [Documentation]    พิมพ์อีเมล "driver@example.com"
    ...                ผลที่คาดหวัง: warning ปรากฏใต้ช่องพิมพ์
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    ส่งข้อมูลมาที่ driver@example.com ได้เลย
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นอีเมลในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT17 - Detect Email Word Form
    [Documentation]    Driver พิมพ์อีเมลแบบหลบเลี่ยงด้วย "แอท" แทน @
    ...                ผลที่คาดหวัง: warning ยังปรากฏ — ระบบ detect evasion ได้
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    test แอท gmail จุด com
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นอีเมลในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT18 - Detect Email Word Form
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    test @ gmail . com
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นอีเมลในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# ── Privacy Detection — LINE ID ──
# ═══════════════════════════════════════════════════════

CHAT19 - Detect Line ID
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    line id: myline123
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นLINE IDในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT20 - Detect Line Link
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    https://line.me/abc123
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นLINE ID, ลิงก์/URLในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT21 - Detect Line Keyword
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    เพิ่มเพื่อน line, แอดมา
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นLINE IDในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session
# ═══════════════════════════════════════════════════════
# ── Privacy Detection — Facebook,Instagram ──
# ═══════════════════════════════════════════════════════

CHAT22 - Warning Appears When Types Facebook Reference
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    messenger,เมสเซนเจอร์,แชทเฟส
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นFacebookในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT23 - Warning Appears When Driver Types Facebook Reference
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    https://www.facebook.com/
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นFacebook, ลิงก์/URLในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT24 - Warning Appears When Types Instagram Username
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    instagram|ig|ไอจี|อินสตาแกรม|อินสตา|insta
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นInstagramในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT25 - Warning Appears When Types Instagram Username
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    https://www.instagram.com/
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นInstagram, ลิงก์/URLในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# ── Privacy Detection — เลขบัญชีธนาคาร / PromptPay ──
# ═══════════════════════════════════════════════════════

CHAT26 - Warning Appears When Driver Types Bank Account Number
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    โอนมาได้เลยครับ กสิกร 123-4-56789-0
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นเลขบัญชีธนาคาร, ที่อยู่ในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT27 - Warning Appears When Driver Types PromptPay Reference
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    พร้อมเพย์ผม 081-234-5678 ครับ
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นเบอร์โทรศัพท์ในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# ── Privacy Detection — ที่อยู่ ──
# ═══════════════════════════════════════════════════════

CHAT28 - Warning Appears When Driver Types Thai Address
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    รับที่บ้านผมนะครับ ซอยลาดพร้าว 10 แขวงจตุจักร
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นที่อยู่ในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

CHAT29 - Warning Appears When Driver Types Thai Postal Code
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    ส่งของมาที่ 10900 ได้เลยครับ
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นที่อยู่ในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# ── Privacy Detection — URL / ลิงก์ ──
# ═══════════════════════════════════════════════════════

CHAT30 - Warning Appears When Driver Types HTTP URL
    [Documentation]    Driver พิมพ์ "https://myprofile.example.com"
    ...                ผลที่คาดหวัง: warning ปรากฏใต้ช่องพิมพ์
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    ดูข้อมูลผมได้ที่ https://myprofile.example.com
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นลิงก์/URLในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session

# ═══════════════════════════════════════════════════════
# ── Privacy Detection — เลขบัตรประชาชน ──
# ═══════════════════════════════════════════════════════

CHAT31 - Warning Appears When Driver Types National ID Number
    [Documentation]    Driver พิมพ์เลขบัตรประชาชน 13 หลัก "1234567890123"
    ...                ผลที่คาดหวัง: warning ปรากฏใต้ช่องพิมพ์
    Login As Passenger
    Sleep    2s
    Go To My Trips Page
    Sleep    2s
    Click Button    xpath://button[contains(@class,'tab-button') and contains(.,'ยืนยันแล้ว')]
    Sleep    2s
    Click Button    xpath://button[normalize-space()='แชทกับผู้ขับ']
    Sleep    2s
    Input Text    ${CHAT TEXTAREA}    เลขบัตรผม 1234567890123 ครับ
    Sleep    1s
    Page Should Contain Element    ${PRIVACY WARNING}
    Page Should Contain    ตรวจพบข้อมูลที่อาจเป็นเลขบัตรประชาชน, เลขบัญชีธนาคารในข้อความ กรุณาระวังการเปิดเผยข้อมูลส่วนตัว
    [Teardown]    Close Browser Session


