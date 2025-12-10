"""Chat room and event management."""

import json
import re
from datetime import datetime
from typing import Optional, Dict, List, Any
from ..storage.db import Database


class ChatManager:
    """Manages chat rooms, events, and notifications."""

    def __init__(self, db: Database):
        """Initialize chat manager.

        Args:
            db: Database instance
        """
        self.db = db

    async def create_chat_room(
        self,
        name: str,
        members: List[str],
        description: Optional[str] = None,
        session_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """Create a new chat room.

        Args:
            name: Unique name for the room
            members: List of persona slugs
            description: Optional room description
            session_id: Optional session to associate with

        Returns:
            Dict with room_id, session_id, and metadata

        Raises:
            ValueError: If room name already exists
        """
        # Check if room exists
        existing = await self.db.fetchone(
            "SELECT id FROM chat_rooms WHERE name = ?",
            (name,)
        )
        if existing:
            raise ValueError(f"Chat room '{name}' already exists")

        # Create room
        cursor = await self.db.execute(
            "INSERT INTO chat_rooms (name, description, session_id) VALUES (?, ?, ?)",
            (name, description, session_id)
        )
        room_id = cursor.lastrowid

        # Add members
        for persona_slug in members:
            await self.db.execute(
                "INSERT INTO room_members (room_id, persona_slug) VALUES (?, ?)",
                (room_id, persona_slug)
            )

            # Create join event
            await self._create_event(
                room_id=room_id,
                event_type="persona_join",
                persona=persona_slug,
                data={"action": "joined", "persona": persona_slug}
            )

        return {
            "room_id": room_id,
            "session_id": session_id,
            "name": name,
            "description": description,
            "members": members
        }

    async def send_message(
        self,
        room_id: int,
        persona: str,
        message: str,
        reply_to_id: Optional[int] = None
    ) -> Dict[str, Any]:
        """Send a message to a chat room.

        Args:
            room_id: ID of the chat room
            persona: Persona slug sending the message
            message: Message content
            reply_to_id: Optional ID of event being replied to

        Returns:
            Dict with event_id and notifications created

        Raises:
            ValueError: If room not found or persona not a member
        """
        # Verify room exists and persona is a member
        await self._verify_membership(room_id, persona)

        # Extract @mentions
        mentions = self._extract_mentions(message)

        # Create message event
        event_data = {
            "message": message,
            "mentions": mentions
        }

        event_id = await self._create_event(
            room_id=room_id,
            event_type="message",
            persona=persona,
            data=event_data,
            reply_to_id=reply_to_id
        )

        # Create notifications for mentioned personas
        notifications = []
        for mentioned_persona in mentions:
            if mentioned_persona != persona:  # Don't notify self
                notif_id = await self._create_notification(
                    persona=mentioned_persona,
                    event_id=event_id,
                    notification_type="mention"
                )
                notifications.append({
                    "notification_id": notif_id,
                    "persona": mentioned_persona
                })

        return {
            "event_id": event_id,
            "room_id": room_id,
            "persona": persona,
            "message": message,
            "mentions": mentions,
            "notifications": notifications
        }

    async def react_to_message(
        self,
        event_id: int,
        persona: str,
        emoji: str
    ) -> Dict[str, Any]:
        """Add an emoji reaction to a message.

        Args:
            event_id: ID of the event to react to
            persona: Persona slug adding the reaction
            emoji: Emoji string

        Returns:
            Dict with reaction event_id

        Raises:
            ValueError: If event not found
        """
        # Verify event exists and get room_id
        event = await self.db.fetchone(
            "SELECT room_id FROM chat_events WHERE id = ?",
            (event_id,)
        )
        if not event:
            raise ValueError(f"Event {event_id} not found")

        room_id = event["room_id"]

        # Verify membership
        await self._verify_membership(room_id, persona)

        # Create reaction event
        reaction_event_id = await self._create_event(
            room_id=room_id,
            event_type="emoji_reaction",
            persona=persona,
            data={"emoji": emoji, "target_event_id": event_id},
            reply_to_id=event_id
        )

        return {
            "event_id": reaction_event_id,
            "target_event_id": event_id,
            "persona": persona,
            "emoji": emoji
        }

    async def share_artifact(
        self,
        room_id: int,
        persona: str,
        artifact_id: int,
        revision: Optional[int] = None
    ) -> Dict[str, Any]:
        """Share an artifact in a chat room.

        Args:
            room_id: ID of the chat room
            persona: Persona slug sharing the artifact
            artifact_id: ID of the artifact
            revision: Optional specific revision number

        Returns:
            Dict with event_id

        Raises:
            ValueError: If room not found or persona not a member
        """
        await self._verify_membership(room_id, persona)

        # Create artifact share event
        event_id = await self._create_event(
            room_id=room_id,
            event_type="artifact_share",
            persona=persona,
            data={
                "artifact_id": artifact_id,
                "revision": revision
            }
        )

        # Notify all room members except the sharer
        members = await self.db.fetchall(
            "SELECT persona_slug FROM room_members WHERE room_id = ?",
            (room_id,)
        )

        notifications = []
        for member in members:
            member_persona = member["persona_slug"]
            if member_persona != persona:
                notif_id = await self._create_notification(
                    persona=member_persona,
                    event_id=event_id,
                    notification_type="artifact_share"
                )
                notifications.append({
                    "notification_id": notif_id,
                    "persona": member_persona
                })

        return {
            "event_id": event_id,
            "room_id": room_id,
            "persona": persona,
            "artifact_id": artifact_id,
            "revision": revision,
            "notifications": notifications
        }

    async def create_todo(
        self,
        room_id: int,
        persona: str,
        description: str,
        assigned_to: Optional[str] = None
    ) -> Dict[str, Any]:
        """Create a shared todo item in a chat room.

        Args:
            room_id: ID of the chat room
            persona: Persona slug creating the todo
            description: Todo description
            assigned_to: Optional persona slug to assign to

        Returns:
            Dict with event_id and notification

        Raises:
            ValueError: If room not found or persona not a member
        """
        await self._verify_membership(room_id, persona)

        # Create todo event
        event_id = await self._create_event(
            room_id=room_id,
            event_type="todo_create",
            persona=persona,
            data={
                "description": description,
                "assigned_to": assigned_to,
                "status": "pending"
            }
        )

        # Notify assigned persona if specified
        notification = None
        if assigned_to and assigned_to != persona:
            notif_id = await self._create_notification(
                persona=assigned_to,
                event_id=event_id,
                notification_type="todo_assign"
            )
            notification = {
                "notification_id": notif_id,
                "persona": assigned_to
            }

        return {
            "event_id": event_id,
            "room_id": room_id,
            "persona": persona,
            "description": description,
            "assigned_to": assigned_to,
            "notification": notification
        }

    async def get_chat_feed(
        self,
        room_id: int,
        since: Optional[str] = None,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get chat event feed for a room.

        Args:
            room_id: ID of the chat room
            since: Optional ISO timestamp to get events after
            limit: Maximum number of events to return (default: 50)

        Returns:
            List of event dicts in chronological order

        Raises:
            ValueError: If room not found
        """
        # Verify room exists
        room = await self.db.fetchone(
            "SELECT id FROM chat_rooms WHERE id = ?",
            (room_id,)
        )
        if not room:
            raise ValueError(f"Chat room {room_id} not found")

        # Build query
        if since:
            events = await self.db.fetchall(
                """
                SELECT * FROM chat_events
                WHERE room_id = ? AND timestamp > ?
                ORDER BY timestamp ASC
                LIMIT ?
                """,
                (room_id, since, limit)
            )
        else:
            events = await self.db.fetchall(
                """
                SELECT * FROM chat_events
                WHERE room_id = ?
                ORDER BY timestamp DESC
                LIMIT ?
                """,
                (room_id, limit)
            )
            # Reverse to get chronological order
            events = list(reversed(events))

        result = []
        for event in events:
            event_dict = dict(event)
            event_dict["data"] = json.loads(event_dict["data"])
            result.append(event_dict)

        return result

    async def get_notifications(
        self,
        persona: str,
        unread_only: bool = True
    ) -> List[Dict[str, Any]]:
        """Get notifications for a persona.

        Args:
            persona: Persona slug
            unread_only: If True, only return unread notifications

        Returns:
            List of notification dicts with event details
        """
        if unread_only:
            rows = await self.db.fetchall(
                """
                SELECT n.id, n.event_id, n.notification_type, n.created_at,
                       e.room_id, e.event_type, e.persona as event_persona,
                       e.data, e.timestamp
                FROM notifications n
                JOIN chat_events e ON n.event_id = e.id
                WHERE n.persona = ? AND n.read_at IS NULL
                ORDER BY n.created_at DESC
                """,
                (persona,)
            )
        else:
            rows = await self.db.fetchall(
                """
                SELECT n.id, n.event_id, n.notification_type, n.created_at,
                       n.read_at,
                       e.room_id, e.event_type, e.persona as event_persona,
                       e.data, e.timestamp
                FROM notifications n
                JOIN chat_events e ON n.event_id = e.id
                WHERE n.persona = ?
                ORDER BY n.created_at DESC
                """,
                (persona,)
            )

        result = []
        for row in rows:
            notif_dict = dict(row)
            notif_dict["event_data"] = json.loads(notif_dict["data"])
            del notif_dict["data"]
            result.append(notif_dict)

        return result

    async def mark_notification_read(self, notification_id: int) -> Dict[str, Any]:
        """Mark a notification as read.

        Args:
            notification_id: ID of the notification

        Returns:
            Dict with updated notification status

        Raises:
            ValueError: If notification not found
        """
        notif = await self.db.fetchone(
            "SELECT id FROM notifications WHERE id = ?",
            (notification_id,)
        )
        if not notif:
            raise ValueError(f"Notification {notification_id} not found")

        now = datetime.utcnow().isoformat()
        await self.db.execute(
            "UPDATE notifications SET read_at = ? WHERE id = ?",
            (now, notification_id)
        )

        return {
            "notification_id": notification_id,
            "read_at": now
        }

    # Helper methods

    async def _verify_membership(self, room_id: int, persona: str):
        """Verify that a persona is a member of a room.

        Raises:
            ValueError: If room doesn't exist or persona is not a member
        """
        member = await self.db.fetchone(
            "SELECT * FROM room_members WHERE room_id = ? AND persona_slug = ?",
            (room_id, persona)
        )
        if not member:
            raise ValueError(f"Persona '{persona}' is not a member of room {room_id}")

    def _extract_mentions(self, message: str) -> List[str]:
        """Extract @mentions from a message.

        Args:
            message: Message text

        Returns:
            List of mentioned persona slugs
        """
        # Match @word patterns
        pattern = r'@([\w-]+)'
        matches = re.findall(pattern, message)
        return list(set(matches))  # Remove duplicates

    async def _create_event(
        self,
        room_id: int,
        event_type: str,
        persona: str,
        data: Dict[str, Any],
        reply_to_id: Optional[int] = None
    ) -> int:
        """Create a chat event.

        Args:
            room_id: ID of the chat room
            event_type: Type of event
            persona: Persona creating the event
            data: Event data dict
            reply_to_id: Optional ID of event being replied to

        Returns:
            ID of created event
        """
        data_json = json.dumps(data)

        cursor = await self.db.execute(
            """
            INSERT INTO chat_events
            (room_id, event_type, persona, data, reply_to_id)
            VALUES (?, ?, ?, ?, ?)
            """,
            (room_id, event_type, persona, data_json, reply_to_id)
        )

        return cursor.lastrowid

    async def _create_notification(
        self,
        persona: str,
        event_id: int,
        notification_type: str
    ) -> int:
        """Create a notification for a persona.

        Args:
            persona: Persona slug to notify
            event_id: ID of the event
            notification_type: Type of notification

        Returns:
            ID of created notification
        """
        cursor = await self.db.execute(
            """
            INSERT INTO notifications (persona, event_id, notification_type)
            VALUES (?, ?, ?)
            """,
            (persona, event_id, notification_type)
        )

        return cursor.lastrowid
