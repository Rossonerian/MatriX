import type { AppState } from "@/types/domain";

export const demoState: AppState = {
  projects: [
    { id: "p1", code: "PRJ-042", name: "Northline Logistics Hub", client: "Northline Infrastructure", status: "On track", progress: 68, budget: 12400000, spent: 7860000, site: "Pune North" },
    { id: "p2", code: "PRJ-038", name: "Riverside Water Treatment", client: "State Water Board", status: "At risk", progress: 44, budget: 8400000, spent: 5120000, site: "Nashik East" },
    { id: "p3", code: "PRJ-035", name: "Aster Manufacturing Expansion", client: "Aster Components", status: "On track", progress: 81, budget: 6200000, spent: 4780000, site: "Aurangabad Plant" },
    { id: "p4", code: "PRJ-029", name: "Metro Depot Fit-out", client: "Urban Transit Corp", status: "Completed", progress: 100, budget: 3900000, spent: 3650000, site: "Pimpri Depot" },
  ],
  requests: [
    { id: "MR-1048", project: "Northline Logistics Hub", site: "Pune North", requester: "Aarav Kulkarni", items: 8, value: 284000, priority: "Urgent", status: "Pending approval", due: "Today" },
    { id: "MR-1047", project: "Riverside Water Treatment", site: "Nashik East", requester: "Meera Shah", items: 4, value: 96000, priority: "High", status: "Clarification", due: "Tomorrow" },
    { id: "MR-1046", project: "Aster Manufacturing Expansion", site: "Aurangabad Plant", requester: "Rohan Patil", items: 12, value: 418000, priority: "Normal", status: "Approved", due: "24 Jul" },
    { id: "MR-1045", project: "Northline Logistics Hub", site: "Pune North", requester: "Aarav Kulkarni", items: 6, value: 152000, priority: "Normal", status: "Issued", due: "22 Jul" },
  ],
  inventory: [
    { id: "i1", sku: "CEM-OPC-043", name: "OPC 43 Grade Cement", category: "Cement", unit: "bags", onHand: 4280, reserved: 860, reorderLevel: 1200, location: "WH-PN / A-03", trend: [55, 64, 58, 71, 68, 76, 80] },
    { id: "i2", sku: "STL-TMT-016", name: "TMT Rebar 16mm", category: "Steel", unit: "tonnes", onHand: 38.4, reserved: 12.2, reorderLevel: 15, location: "WH-PN / Y-01", trend: [82, 72, 70, 64, 59, 54, 48] },
    { id: "i3", sku: "VAL-BUT-200", name: "Butterfly Valve 200mm", category: "Mechanical", unit: "units", onHand: 14, reserved: 10, reorderLevel: 8, location: "WH-NE / B-07", trend: [42, 43, 45, 47, 48, 49, 50] },
    { id: "i4", sku: "CAB-XLPE-4C", name: "XLPE Cable 4 Core", category: "Electrical", unit: "metres", onHand: 860, reserved: 720, reorderLevel: 500, location: "WH-AP / C-11", trend: [68, 64, 58, 51, 48, 45, 39] },
    { id: "i5", sku: "PPE-HELM-01", name: "Safety Helmet", category: "Safety", unit: "units", onHand: 118, reserved: 18, reorderLevel: 60, location: "WH-PN / S-02", trend: [22, 23, 25, 24, 26, 28, 31] },
  ],
  waste: [
    { id: "W-202", material: "TMT Rebar 12mm", project: "Northline Logistics Hub", source: "Cutting", disposition: "Return to warehouse", quantity: 0.42, unit: "tonnes", cost: 28400, status: "Pending approval" },
    { id: "W-201", material: "OPC 43 Grade Cement", project: "Riverside Water Treatment", source: "Storage", disposition: "Disposal", quantity: 84, unit: "bags", cost: 46200, status: "Approved" },
    { id: "W-200", material: "Scaffolding timber", project: "Metro Depot Fit-out", source: "Demolition", disposition: "Salvage", quantity: 2.8, unit: "tonnes", cost: 18400, status: "Resolved" },
  ],
  production: [
    { id: "MO-3021", product: "Control Panel CP-400", line: "Assembly L2", quantity: 120, completed: 78, status: "In progress", due: "24 Jul" },
    { id: "MO-3020", product: "Pump Skid PS-90", line: "Fabrication L1", quantity: 28, completed: 28, status: "Quality check", due: "Today" },
    { id: "MO-3019", product: "Valve Actuator VA-12", line: "Assembly L3", quantity: 240, completed: 0, status: "Planned", due: "28 Jul" },
  ],
  suppliers: [
    { id: "s1", name: "BuildCore Materials", category: "Cement & aggregates", rating: 4.8, onTime: 96, status: "Preferred" },
    { id: "s2", name: "Apex Steelworks", category: "Structural steel", rating: 4.4, onTime: 91, status: "Preferred" },
    { id: "s3", name: "Nova Industrial Supply", category: "MRO & electrical", rating: 3.7, onTime: 78, status: "Watch" },
  ],
};
