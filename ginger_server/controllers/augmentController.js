const augmentService = require('../services/augmentService');

class AugmentController {
  /**
   * Analyze user input using Augment API
   * POST /augment/analyze
   */
  async analyzeInput(req, res) {
    try {
      const { input, options = {} } = req.body;

      // Validate request body
      if (!input) {
        return res.status(400).json({
          success: false,
          error: 'Input is required',
          message: 'Please provide input text to analyze'
        });
      }

      if (typeof input !== 'string') {
        return res.status(400).json({
          success: false,
          error: 'Invalid input type',
          message: 'Input must be a string'
        });
      }

      if (input.trim().length === 0) {
        return res.status(400).json({
          success: false,
          error: 'Empty input',
          message: 'Input cannot be empty'
        });
      }

      // Validate input length (optional - adjust as needed)
      if (input.length > 10000) {
        return res.status(400).json({
          success: false,
          error: 'Input too long',
          message: 'Input must be less than 10,000 characters'
        });
      }

      console.log(`Processing analysis request for input: ${input.substring(0, 100)}${input.length > 100 ? '...' : ''}`);

      // Call Augment service
      const result = await augmentService.analyzeInput(input, options);

      if (result.success) {
        res.status(200).json({
          success: true,
          data: result.data,
          timestamp: result.timestamp,
          message: 'Analysis completed successfully'
        });
      } else {
        res.status(500).json({
          success: false,
          error: result.error,
          timestamp: result.timestamp,
          message: 'Analysis failed'
        });
      }

    } catch (error) {
      console.error('Error in analyzeInput controller:', error);
      
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: 'An unexpected error occurred while processing your request',
        timestamp: new Date().toISOString()
      });
    }
  }

  /**
   * Health check for Augment service
   * GET /augment/health
   */
  async healthCheck(req, res) {
    try {
      const healthStatus = await augmentService.healthCheck();
      
      const statusCode = healthStatus.status === 'healthy' ? 200 : 503;
      
      res.status(statusCode).json({
        service: 'augment',
        status: healthStatus.status,
        timestamp: new Date().toISOString(),
        ...(healthStatus.error && { error: healthStatus.error }),
        ...(healthStatus.response && { details: healthStatus.response })
      });

    } catch (error) {
      console.error('Error in healthCheck controller:', error);
      
      res.status(503).json({
        service: 'augment',
        status: 'unhealthy',
        error: 'Health check failed',
        message: error.message,
        timestamp: new Date().toISOString()
      });
    }
  }

  /**
   * Get service information
   * GET /augment/info
   */
  async getServiceInfo(req, res) {
    try {
      res.status(200).json({
        service: 'Augment API Integration',
        version: '1.0.0',
        description: 'Service for integrating with Augment Code API',
        endpoints: {
          analyze: {
            method: 'POST',
            path: '/augment/analyze',
            description: 'Analyze user input using Augment API'
          },
          health: {
            method: 'GET',
            path: '/augment/health',
            description: 'Check Augment service health'
          },
          info: {
            method: 'GET',
            path: '/augment/info',
            description: 'Get service information'
          }
        },
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      console.error('Error in getServiceInfo controller:', error);
      
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: 'Failed to retrieve service information',
        timestamp: new Date().toISOString()
      });
    }
  }
}

module.exports = new AugmentController();
