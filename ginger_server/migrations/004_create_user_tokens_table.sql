-- Migration: Create user_tokens table for multiple active tokens per user
-- This allows users to be logged in on multiple devices/platforms simultaneously

-- Create user_tokens table
CREATE TABLE IF NOT EXISTS user_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure unique combination of user_id and token
    UNIQUE(user_id, token)
);

-- Create index for faster token lookups
CREATE INDEX IF NOT EXISTS idx_user_tokens_user_id ON user_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_user_tokens_token ON user_tokens(token);
CREATE INDEX IF NOT EXISTS idx_user_tokens_expires_at ON user_tokens(expires_at);

-- Migrate existing tokens from app_user table to user_tokens table
INSERT INTO user_tokens (user_id, token, expires_at, created_at, last_used_at)
SELECT 
    id as user_id,
    auth_token as token,
    auth_token_expires as expires_at,
    NOW() as created_at,
    last_active_at as last_used_at
FROM app_user 
WHERE auth_token IS NOT NULL 
  AND auth_token_expires IS NOT NULL 
  AND auth_token_expires > NOW()
ON CONFLICT (user_id, token) DO NOTHING;

-- Add cleanup function to remove expired tokens
CREATE OR REPLACE FUNCTION cleanup_expired_tokens()
RETURNS void AS $$
BEGIN
    DELETE FROM user_tokens WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Create a scheduled job to clean up expired tokens (optional - can be run manually)
-- This would typically be handled by a cron job or scheduled task
COMMENT ON FUNCTION cleanup_expired_tokens() IS 'Function to clean up expired tokens. Should be called periodically via cron job.';
