/**
 * Instruction detail page — server wrapper for static export.
 *
 * generateStaticParams pre-renders a route for every instruction in the
 * mock dataset. The actual rendering is handled by InstructionDetailClient
 * which reads the uuid from the URL at runtime via useParams.
 */

import { INSTRUCTIONS } from "@/lib/api/mock/instructions";
import { InstructionDetailClient } from "./InstructionDetailClient";

export function generateStaticParams(): { uuid: string }[] {
  return INSTRUCTIONS.map((instr) => ({ uuid: instr.uuid }));
}

export default function InstructionDetailPage() {
  return <InstructionDetailClient />;
}
