const asyncHandler = require("express-async-handler");
const { signToken } = require("../utils/jwt");
const userService = require("../services/user.service");
const ApiError = require("../utils/ApiError");
const blacklistService = require("../services/blacklist.service");
const login = asyncHandler(async (req, res) => {
  const { email, username, password } = req.body;

  let user;
  if (email) {
    user = await userService.getUserByEmail(email);
  } else if (username) {
    user = await userService.getUserByUsername(username);
  }
  await blacklistService.checkUserAccess(user.id);

  if (email) {
    user = await userService.getUserByEmail(email);
  } else if (username) {
    user = await userService.getUserByUsername(username);
  }
  //check if accout have lock because enter wrong answer >= 3 attemps
  //and check if not lock timeout
    if (user?.lockUntil) {

      const now = new Date();

      // ถ้ายัง lock อยู่
      if (user.lockUntil > now) {
        throw new ApiError(403, "Account locked. Try again later.");
      }

      // ถ้า lock หมดเวลาแล้ว → reset attempts
      await userService.resetLoginAttempts(user.id);

      user.loginAttempts = 0;
      user.lockUntil = null;
    }
  if (user && !user.isActive) {
    throw new ApiError(401, "Your account has been deactivated.");
  }

  const passwordIsValid = user
    ? await userService.comparePassword(user, password)
    : false;
      if (!user || !passwordIsValid) {

        if (user) {
          // increase login attemps if enter wrong password
          const updatedUser = await userService.increaseLoginAttempts(user);
          //////////////////////
          


          
          const remainingAttempts = 3 - updatedUser.loginAttempts;

          if (updatedUser.lockUntil) {
            const remainingMs = new Date(updatedUser.lockUntil) - new Date();
            const remainingMinutes = Math.ceil(remainingMs / 60000);

            throw new ApiError(
              403,
              `บัญชีถูกล็อก กรุณาลองใหม่อีก ${remainingMinutes} นาที`,
              {
                lockUntil: updatedUser.lockUntil
              }
            );
          }

          throw new ApiError(
            401,
            `รหัสผ่านไม่ถูกต้อง เหลืออีก ${remainingAttempts} ครั้งก่อนถูกล็อก`
          );
        }

        throw new ApiError(401, "Invalid credentials");
      }



// check if password expired
let passwordExpired = false;
  if(email){
    const result = await userService.check_last_password_change_from_email(email);
    if (result.passwordExpired) {
      passwordExpired = result.passwordExpired;
  }  
  }
  if(username){
    const result = await userService.check_last_password_change_from_username(username);
    if (result.passwordExpired) {
      passwordExpired = result.passwordExpired;
  }  
  }
  console.log(passwordExpired)
  const token = signToken({ sub: user.id, role: user.role });

  await userService.resetLoginAttempts(user.id);
  const {
    password: _,
    gender,
    phoneNumber,
    otpCode,
    nationalIdNumber,
    nationalIdPhotoUrl,
    nationalIdExpiryDate,
    selfiePhotoUrl,
    isVerified,
    isActive,
    lastLogin,
    createdAt,
    updatedAt,
    username: __,
    email: ___,
    ...safeUser
  } = user;

  res.status(200).json({
    success: true,
    message: "Login successful",
    data: { token, user: safeUser,passwordExpired },
  });
});

const changePassword = asyncHandler(async (req, res) => {
  const userId = req.user.sub;
  const { currentPassword, newPassword } = req.body;

  const result = await userService.updatePassword(
    userId,
    currentPassword,
    newPassword,
  );

  if (!result.success) {
    if (result.error === "INCORRECT_PASSWORD") {
      throw new ApiError(401, "Incorrect current password.");
    }
    if (result.error === "PASSWORD_IS_PERMUTATION") {
      throw new ApiError(400, "New password must not be a rearrangement of the current password.");
    }
    if (result.error === "PASSWORD_TOO_COMMON") {
      throw new ApiError(400, "New password is in the common brute-force word list (NCSC UK). Please choose a longer or more unique password.");
    }
    throw new ApiError(500, "Could not update password.");
  }

  res.status(200).json({
    success: true,
    message: "Password changed successfully",
    data: null,
  });
});

module.exports = { login, changePassword };
