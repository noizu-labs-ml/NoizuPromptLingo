import { config } from "dotenv";
import { WeaviateStore } from "./weaviate.js";

config({ path: "../../.env.development" });

async function main() {
  const store = new WeaviateStore(process.env.WEAVIATE_URL ?? "http://localhost:8080");
  await store.connect();
  await store.ensureCollection();
  console.log("Weaviate collection 'MemoryEntry' ensured.");
  await store.close();
}

main().catch(console.error);
