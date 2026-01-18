'use strict';

const NodeGeocoder = require('./index.js');

/**
 * Test coordinates - various locations around the world
 */
const TEST_COORDINATES = [
  {
    name: 'Eiffel Tower, Paris',
    lat: 48.8584,
    lon: 2.2945
  },
  {
    name: 'Statue of Liberty, New York',
    lat: 40.6892,
    lon: -74.0445
  },
  {
    name: 'Christ the Redeemer, Rio de Janeiro',
    lat: -22.9519,
    lon: -43.2105
  },
  {
    name: 'Colosseum, Rome',
    lat: 41.8902,
    lon: 12.4924
  },
  {
    name: 'Big Ben, London',
    lat: 51.4975,
    lon: -0.1248
  }
];

async function testReverseGeocoding() {
  console.log('🌍 Testing Reverse Geocoding with node-geocoder\n');
  console.log('='.repeat(70));

  // Test with OpenStreetMap (free, no API key needed)
  const geocoder = NodeGeocoder({
    provider: 'openstreetmap',
    formatter: null
  });

  for (const coord of TEST_COORDINATES) {
    try {
      console.log(`\n📍 Testing: ${coord.name}`);
      console.log(`   Coordinates: (${coord.lat}, ${coord.lon})`);
      console.log('   Fetching...');

      const result = await geocoder.reverse({
        lat: coord.lat,
        lon: coord.lon
      });

      if (result && result.length > 0) {
        const address = result[0];
        console.log(`   ✅ Result:`);
        console.log(`      Address: ${address.streetName || ''} ${address.streetNumber || ''}`);
        console.log(`      City: ${address.city || ''}`);
        console.log(`      Country: ${address.country || ''}`);
        console.log(`      ZipCode: ${address.zipcode || ''}`);
        console.log(`      Provider: ${address.provider || ''}`);
      } else {
        console.log(`   ⚠️  No results found`);
      }
    } catch (error) {
      console.log(`   ❌ Error: ${error.message}`);
    }

    // Wait a bit between requests to avoid rate limiting
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  console.log('\n' + '='.repeat(70));
  console.log('✅ Test completed!\n');
}

// Run tests
testReverseGeocoding().catch(error => {
  console.error('Test failed:', error);
  process.exit(1);
});
