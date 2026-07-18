import { describe, expect, it } from "vitest";
import { canUseFeature } from "@/lib/entitlements";

describe("MatriX plan entitlements", () => {
  it("keeps construction waste on Base+ and above", () => {
    expect(canUseFeature("Base", "waste")).toBe(false);
    expect(canUseFeature("Base+", "waste")).toBe(true);
  });
  it("keeps production and AI features on Pro and Max", () => {
    expect(canUseFeature("Base+", "industrial")).toBe(false);
    expect(canUseFeature("Pro", "industrial")).toBe(true);
    expect(canUseFeature("Max", "ai_forecasting")).toBe(true);
  });
});
