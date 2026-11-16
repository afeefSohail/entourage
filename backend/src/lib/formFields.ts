import { z } from "zod";

// The iOS client sends most bodies form-encoded, so numbers and booleans arrive as strings.

export const formInt = () => z.coerce.number().int();

// Alamofire encodes Bool as "1"/"0"; z.coerce.boolean would read "0" as true.
export const formBool = () =>
  z.preprocess((v) => {
    if (v === "1" || v === "true") return true;
    if (v === "0" || v === "false") return false;
    return v;
  }, z.boolean());
