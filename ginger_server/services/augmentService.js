const https = require('https');
const http = require('http');
const { URL } = require('url');

class AugmentService {
  constructor() {
    this.apiUrl = process.env.AUGMENT_API_URL || 'https://api.augmentcode.com';
    this.apiKey = process.env.AUGMENT_API_KEY;
    this.apiVersion = process.env.AUGMENT_API_VERSION || 'v1';
    this.timeout = parseInt(process.env.REQUEST_TIMEOUT) || 30000;
  }

  /**
   * Analyze user input using Augment API
   * @param {string} userInput - The user input to analyze
   * @param {Object} options - Additional options for the analysis
   * @returns {Promise<Object>} - The analysis result from Augment API
   */
  async analyzeInput(userInput, options = {}) {
    try {
      if (!this.apiKey) {
        throw new Error('Augment API key is not configured');
      }

      if (!userInput || typeof userInput !== 'string') {
        throw new Error('User input is required and must be a string');
      }

      const requestData = {
        input: userInput,
        version: this.apiVersion,
        ...options
      };

      const response = await this.makeRequest('/analyze', 'POST', requestData);
      
      return {
        success: true,
        data: response,
        timestamp: new Date().toISOString()
      };

    } catch (error) {
      console.error('Error in analyzeInput:', error.message);
      
      return {
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }

  /**
   * Make HTTP request to Augment API
   * @param {string} endpoint - API endpoint
   * @param {string} method - HTTP method
   * @param {Object} data - Request data
   * @returns {Promise<Object>} - API response
   */
  async makeRequest(endpoint, method = 'GET', data = null) {
    return new Promise((resolve, reject) => {
      const url = new URL(`${this.apiUrl}${endpoint}`);
      const isHttps = url.protocol === 'https:';
      const httpModule = isHttps ? https : http;

      const requestOptions = {
        hostname: url.hostname,
        port: url.port || (isHttps ? 443 : 80),
        path: url.pathname + url.search,
        method: method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.apiKey}`,
          'User-Agent': 'Ginger-Server/1.0.0'
        },
        timeout: this.timeout
      };

      if (data && (method === 'POST' || method === 'PUT' || method === 'PATCH')) {
        const jsonData = JSON.stringify(data);
        requestOptions.headers['Content-Length'] = Buffer.byteLength(jsonData);
      }

      const req = httpModule.request(requestOptions, (res) => {
        let responseData = '';

        res.on('data', (chunk) => {
          responseData += chunk;
        });

        res.on('end', () => {
          try {
            const parsedData = JSON.parse(responseData);
            
            if (res.statusCode >= 200 && res.statusCode < 300) {
              resolve(parsedData);
            } else {
              reject(new Error(`API request failed with status ${res.statusCode}: ${parsedData.message || responseData}`));
            }
          } catch (parseError) {
            reject(new Error(`Failed to parse API response: ${parseError.message}`));
          }
        });
      });

      req.on('error', (error) => {
        reject(new Error(`Request failed: ${error.message}`));
      });

      req.on('timeout', () => {
        req.destroy();
        reject(new Error('Request timeout'));
      });

      if (data && (method === 'POST' || method === 'PUT' || method === 'PATCH')) {
        req.write(JSON.stringify(data));
      }

      req.end();
    });
  }

  /**
   * Health check for Augment API
   * @returns {Promise<Object>} - Health status
   */
  async healthCheck() {
    try {
      // This is a placeholder - replace with actual health check endpoint
      const response = await this.makeRequest('/health', 'GET');
      return {
        status: 'healthy',
        response: response
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message
      };
    }
  }
}

module.exports = new AugmentService();
