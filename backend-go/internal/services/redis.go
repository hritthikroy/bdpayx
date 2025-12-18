package services

import (
	"context"
	"fmt"
	"strconv"
	"time"

	"github.com/redis/go-redis/v9"
)

type RedisService struct {
	client *redis.Client
	ctx    context.Context
}

func NewRedisService(host string, port int, password string) *RedisService {
	rdb := redis.NewClient(&redis.Options{
		Addr:     host + ":" + strconv.Itoa(port),
		Password: password,
		DB:       0,
	})

	ctx := context.Background()
	
	// Test connection
	_, err := rdb.Ping(ctx).Result()
	if err != nil {
		fmt.Printf("Warning: Redis connection failed: %v\n", err)
		return nil
	}

	fmt.Println("✅ Redis connected successfully")
	
	return &RedisService{
		client: rdb,
		ctx:    ctx,
	}
}

func (r *RedisService) Set(key string, value interface{}, expiration time.Duration) error {
	if r == nil || r.client == nil {
		return fmt.Errorf("redis client not available")
	}
	return r.client.Set(r.ctx, key, value, expiration).Err()
}

func (r *RedisService) Get(key string) (string, error) {
	if r == nil || r.client == nil {
		return "", fmt.Errorf("redis client not available")
	}
	return r.client.Get(r.ctx, key).Result()
}

func (r *RedisService) Delete(key string) error {
	if r == nil || r.client == nil {
		return fmt.Errorf("redis client not available")
	}
	return r.client.Del(r.ctx, key).Err()
}

func (r *RedisService) Exists(key string) (bool, error) {
	if r == nil || r.client == nil {
		return false, fmt.Errorf("redis client not available")
	}
	result, err := r.client.Exists(r.ctx, key).Result()
	return result > 0, err
}