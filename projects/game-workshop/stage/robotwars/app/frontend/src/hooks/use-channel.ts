"use client";

import { useEffect, useRef, useState } from "react";
import { joinChannel } from "@/lib/socket";
import type { Channel } from "phoenix";

export function useChannel(topic: string | null) {
  const channelRef = useRef<Channel | null>(null);
  const [connected, setConnected] = useState(false);

  useEffect(() => {
    if (!topic) return;

    const channel = joinChannel(topic);
    channelRef.current = channel;

    channel.onClose(() => setConnected(false));
    channel.onError(() => setConnected(false));

    const ref = channel.on("phx_reply", () => setConnected(true));

    return () => {
      channel.off("phx_reply", ref);
      channel.leave();
      channelRef.current = null;
      setConnected(false);
    };
  }, [topic]);

  function push(event: string, payload: Record<string, unknown> = {}) {
    channelRef.current?.push(event, payload);
  }

  return { channel: channelRef.current, connected, push };
}
