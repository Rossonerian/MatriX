export type Status = "On track" | "At risk" | "Completed" | "Pending" | "In progress" | "Draft" | "Approved" | "Rejected" | "Quality check";

export type InventoryItem = {
  id: string;
  sku: string;
  name: string;
  category: string;
  unit: string;
  onHand: number;
  reserved: number;
  reorderLevel: number;
  location: string;
  trend: number[];
};

export type MaterialRequest = {
  id: string;
  project: string;
  site: string;
  requester: string;
  items: number;
  value: number;
  priority: "Urgent" | "High" | "Normal";
  status: "Pending approval" | "Approved" | "Clarification" | "Rejected" | "Issued";
  due: string;
};

export type Project = {
  id: string;
  code: string;
  name: string;
  client: string;
  status: Status;
  progress: number;
  budget: number;
  spent: number;
  site: string;
};

export type WasteRecord = {
  id: string;
  material: string;
  project: string;
  source: string;
  disposition: string;
  quantity: number;
  unit: string;
  cost: number;
  status: "Pending approval" | "Approved" | "Resolved";
};

export type ProductionOrder = {
  id: string;
  product: string;
  line: string;
  quantity: number;
  completed: number;
  status: "In progress" | "Quality check" | "Planned" | "Completed";
  due: string;
};

export type Supplier = {
  id: string;
  name: string;
  category: string;
  rating: number;
  onTime: number;
  status: "Preferred" | "Watch" | "Pending review";
};

export type AppState = {
  requests: MaterialRequest[];
  waste: WasteRecord[];
  inventory: InventoryItem[];
  projects: Project[];
  production: ProductionOrder[];
  suppliers: Supplier[];
};
