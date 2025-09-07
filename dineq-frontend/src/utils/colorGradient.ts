import tinycolor from "tinycolor2";

export function getGradientFromColor(hexColor: string) {
  const light = tinycolor(hexColor).lighten(30).toHexString();
  const dark = tinycolor(hexColor).darken(30).toHexString();

  return { light, dark };
}
