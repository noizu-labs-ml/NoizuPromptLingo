import { CHAT_ROOMS } from "@/lib/api/mock/collab";
import ChatRoomClient from "./ChatRoomClient";

export function generateStaticParams() {
  return CHAT_ROOMS.map((room) => ({ id: room.id }));
}

export default function ChatRoomPage() {
  return <ChatRoomClient />;
}
