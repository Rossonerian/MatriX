export type Plan = "Base" | "Base+" | "Pro" | "Max";
export type FeatureKey = "procurement" | "waste" | "industrial" | "analytics" | "ai_forecasting" | "audit_export";

const rank: Record<Plan, number> = { Base: 1, "Base+": 2, Pro: 3, Max: 4 };
const featureMinimum: Record<FeatureKey, Plan> = { procurement: "Base+", waste: "Base+", industrial: "Pro", analytics: "Pro", ai_forecasting: "Pro", audit_export: "Pro" };

export function canUseFeature(plan: Plan, feature: FeatureKey): boolean {
  return rank[plan] >= rank[featureMinimum[feature]];
}

export function planLabel(plan: Plan): string {
  return `${plan} plan`;
}
