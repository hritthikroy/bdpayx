package handlers

import (
	"net/http"

	"bdpayx-backend/internal/models"
	"bdpayx-backend/internal/services"

	"github.com/gin-gonic/gin"
)

type ExchangeHandler struct {
	rateService *services.RateService
}

func NewExchangeHandler(rateService *services.RateService) *ExchangeHandler {
	return &ExchangeHandler{rateService: rateService}
}

func (h *ExchangeHandler) GetRates(c *gin.Context) {
	rates, err := h.rateService.GetRates()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"rates": rates})
}

func (h *ExchangeHandler) CalculateExchange(c *gin.Context) {
	var req models.ExchangeCalculateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	result, err := h.rateService.CalculateExchange(req.FromCurrency, req.ToCurrency, req.Amount)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, result)
}