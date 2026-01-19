'use strict';

const express = require('express');
const NodeGeocoder = require('./index.js');

const app = express();
const PORT = process.env.PORT || 3002;

// Cache em memória para performance
const cache = new Map();
const CACHE_MAX_SIZE = 10000;
const CACHE_TTL = 3600000; // 1 hora em ms

// Limpar cache periodicamente
setInterval(() => {
  const now = Date.now();
  for (const [key, value] of cache.entries()) {
    if (now - value.timestamp > CACHE_TTL) {
      cache.delete(key);
    }
  }
}, 60000); // A cada 1 minuto

// Middleware
app.use(express.json());

// Configurações de providers disponíveis
const PROVIDERS = {
  openstreetmap: {
    provider: 'openstreetmap',
    formatter: null,
    osmServer: process.env.OSM_SERVER || 'http://localhost:8080'
  },
  google: {
    provider: 'google',
    apiKey: process.env.GOOGLE_API_KEY || '',
    formatter: null
  },
  mapquest: {
    provider: 'mapquest',
    apiKey: process.env.MAPQUEST_API_KEY || '',
    formatter: null
  },
  locationiq: {
    provider: 'locationiq',
    apiKey: process.env.LOCATIONIQ_API_KEY || '',
    formatter: null
  },
  opencage: {
    provider: 'opencage',
    apiKey: process.env.OPENCAGE_API_KEY || '',
    formatter: null
  },
  tomtom: {
    provider: 'tomtom',
    apiKey: process.env.TOMTOM_API_KEY || '',
    formatter: null
  },
  here: {
    provider: 'here',
    apiKey: process.env.HERE_API_KEY || '',
    formatter: null
  },
  mapbox: {
    provider: 'mapbox',
    apiKey: process.env.MAPBOX_API_KEY || '',
    formatter: null
  }
};

// Instancias de geocoders (lazy loading)
const geocoders = {};

/**
 * Get or create geocoder instance
 */
function getGeocoder(provider = 'openstreetmap') {
  if (!geocoders[provider]) {
    const config = PROVIDERS[provider];
    if (!config) {
      throw new Error(`Provider "${provider}" not supported`);
    }
    geocoders[provider] = NodeGeocoder(config);
  }
  return geocoders[provider];
}

/**
 * Health check endpoint
 */
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

/**
 * Get available providers
 */
app.get('/api/providers', (req, res) => {
  res.json({
    providers: Object.keys(PROVIDERS),
    default: 'openstreetmap'
  });
});

/**
 * Reverse geocoding endpoint
 * Accepts lat and lng as query parameters or in body
 */
app.post('/api/search_reverse', async (req, res) => {
  try {
    const { latitude, longitude, lat, lng, provider = 'openstreetmap', zoom = 18 } = {
      ...req.query,
      ...req.body
    };

    // Validação de coordenadas
    const latitude_val = parseFloat(latitude || lat);
    const longitude_val = parseFloat(longitude || lng);

    if (isNaN(latitude_val) || isNaN(longitude_val)) {
      return res.status(400).json({
        error: 'Invalid coordinates',
        message: 'latitude (or lat) and longitude (or lng) must be valid numbers',
        received: { latitude: latitude || lat, longitude: longitude || lng }
      });
    }

    // Caso especial: latitude=0 e longitude=0 (coordenadas não disponíveis)
    if (latitude_val === 0 && longitude_val === 0) {
      return res.json({
        success: true,
        provider,
        coordinates: {
          latitude: 0,
          longitude: 0
        },
        results: [{
          latitude: 0,
          longitude: 0,
          formattedAddress: 'cidade não informada',
          country: '',
          city: 'cidade não informada',
          state: '',
          countryCode: '',
          neighbourhood: '',
          provider: provider
        }],
        skipped: true,
        message: 'Coordinates 0,0 skipped - no geocoding performed',
        timestamp: new Date().toISOString()
      });
    }

    if (latitude_val < -90 || latitude_val > 90) {
      return res.status(400).json({
        error: 'Invalid latitude',
        message: 'Latitude must be between -90 and 90'
      });
    }

    if (longitude_val < -180 || longitude_val > 180) {
      return res.status(400).json({
        error: 'Invalid longitude',
        message: 'Longitude must be between -180 and 180'
      });
    }

    // Validar provider
    if (!PROVIDERS[provider]) {
      return res.status(400).json({
        error: 'Invalid provider',
        message: `Provider "${provider}" not supported. Available: ${Object.keys(PROVIDERS).join(', ')}`
      });
    }

    // Verificar cache
    const cacheKey = `${provider}:${latitude_val.toFixed(6)}:${longitude_val.toFixed(6)}`;
    if (cache.has(cacheKey)) {
      const cached = cache.get(cacheKey);
      return res.json({
        ...cached.data,
        cached: true,
        cacheAge: Math.round((Date.now() - cached.timestamp) / 1000)
      });
    }

    const geocoder = getGeocoder(provider);

    // Fazer reverse geocoding
    const result = await geocoder.reverse({
      lat: latitude_val,
      lon: longitude_val
    });

    const response = {
      success: true,
      provider,
      coordinates: {
        latitude: latitude_val,
        longitude: longitude_val
      },
      results: result || [],
      timestamp: new Date().toISOString()
    };

    // Armazenar no cache
    if (cache.size >= CACHE_MAX_SIZE) {
      const firstKey = cache.keys().next().value;
      cache.delete(firstKey);
    }
    cache.set(cacheKey, {
      data: response,
      timestamp: Date.now()
    });

    res.json(response);
  } catch (error) {
    console.error('Reverse geocoding error:', error);
    res.status(500).json({
      error: 'Reverse geocoding failed',
      message: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

/**
 * GET alternative for reverse geocoding (compatible with n8n)
 */
app.get('/api/search_reverse', async (req, res) => {
  try {
    const { latitude, longitude, lat, lng, provider = 'openstreetmap' } = req.query;

    const latitude_val = parseFloat(latitude || lat);
    const longitude_val = parseFloat(longitude || lng);

    if (isNaN(latitude_val) || isNaN(longitude_val)) {
      return res.status(400).json({
        error: 'Invalid coordinates',
        message: 'latitude (or lat) and longitude (or lng) must be valid numbers'
      });
    }

    // Caso especial: latitude=0 e longitude=0 (coordenadas não disponíveis)
    if (latitude_val === 0 && longitude_val === 0) {
      return res.json({
        success: true,
        provider,
        coordinates: {
          latitude: 0,
          longitude: 0
        },
        results: [{
          latitude: 0,
          longitude: 0,
          formattedAddress: 'cidade não informada',
          country: '',
          city: 'cidade não informada',
          state: '',
          countryCode: '',
          neighbourhood: '',
          provider: provider
        }],
        skipped: true,
        message: 'Coordinates 0,0 skipped - no geocoding performed',
        timestamp: new Date().toISOString()
      });
    }

    if (latitude_val < -90 || latitude_val > 90 || longitude_val < -180 || longitude_val > 180) {
      return res.status(400).json({
        error: 'Invalid coordinates',
        message: 'Latitude must be between -90 and 90, Longitude between -180 and 180'
      });
    }

    if (!PROVIDERS[provider]) {
      return res.status(400).json({
        error: 'Invalid provider',
        message: `Provider "${provider}" not supported`
      });
    }

    const geocoder = getGeocoder(provider);
    const result = await geocoder.reverse({
      lat: latitude_val,
      lon: longitude_val
    });

    res.json({
      success: true,
      provider,
      coordinates: {
        latitude: latitude_val,
        longitude: longitude_val
      },
      results: result || [],
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Reverse geocoding error:', error);
    res.status(500).json({
      error: 'Reverse geocoding failed',
      message: error.message
    });
  }
});

/**
 * Geocoding endpoint (forward)
 */
app.post('/api/search', async (req, res) => {
  try {
    const { address, provider = 'openstreetmap' } = req.body;

    if (!address) {
      return res.status(400).json({
        error: 'Missing address',
        message: 'address parameter is required'
      });
    }

    if (!PROVIDERS[provider]) {
      return res.status(400).json({
        error: 'Invalid provider',
        message: `Provider "${provider}" not supported`
      });
    }

    const geocoder = getGeocoder(provider);
    const result = await geocoder.geocode(address);

    res.json({
      success: true,
      provider,
      address,
      results: result || [],
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Geocoding error:', error);
    res.status(500).json({
      error: 'Geocoding failed',
      message: error.message
    });
  }
});

/**
 * Error handler
 */
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message,
    timestamp: new Date().toISOString()
  });
});

/**
 * 404 handler
 */
app.use((req, res) => {
  res.status(404).json({
    error: 'Not found',
    message: 'The requested endpoint does not exist',
    availableEndpoints: [
      'GET /health',
      'GET /api/providers',
      'GET /api/search_reverse?latitude=X&longitude=Y&provider=openstreetmap',
      'POST /api/search_reverse',
      'POST /api/search'
    ]
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🌍 Geocoder server running on port ${PORT}`);
  console.log(`Available providers: ${Object.keys(PROVIDERS).join(', ')}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`API docs: http://localhost:${PORT}/api/providers`);
});