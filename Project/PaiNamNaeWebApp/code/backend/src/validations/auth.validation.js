const { z } = require('zod');
const { isCommonPassword } = require('../utils/commonPasswords');

const loginSchema = z.object({
    email: z.string().email('Invalid email format').optional(),
    username: z.string().min(6, 'Username must be at least 6 characters').optional(),
    password: z.string().min(6, 'Password must be at least 6 characters'),
}).refine((data) => data.email || data.username, {
    message: "Either email or username is required",
});

const changePasswordSchema = z.object({
    currentPassword: z.string().min(1, "Current password is required"),
    newPassword: z.string().min(10, "New password must be at least 10 characters (NCSC UK)")
        .refine(pw => !isCommonPassword(pw), {
            message: "New password is in the common brute-force word list (NCSC UK). Please choose a longer or more unique password.",
        }),
    confirmNewPassword: z.string().min(1, "Password confirmation is required"),
}).refine((data) => data.newPassword === data.confirmNewPassword, {
    message: "New password and confirmation do not match",
    path: ["confirmNewPassword"],
});

module.exports = { loginSchema, changePasswordSchema };