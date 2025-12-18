package handlers

import (
	"bdpayx-backend/internal/websocket"

	"github.com/gin-gonic/gin"
)

type WebSocketHandler struct {
	hub *websocket.Hub
}

func NewWebSocketHandler(hub *websocket.Hub) *WebSocketHandler {
	return &WebSocketHandler{hub: hub}
}

func (h *WebSocketHandler) HandleWebSocket(c *gin.Context) {
	h.hub.ServeWS(c.Writer, c.Request)
}