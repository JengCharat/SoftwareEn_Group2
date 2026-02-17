const { z } = require("zod");

const nationalIdNumberValidation = z.object({
  nationalIdNumber: z
    .string()
    .regex(/^\d{13}$/, "National ID must be exactly 13 digits"),
});

module.exports = {
  nationalIdNumberValidation,
};
