const fs = require('fs');
const path = require('path');
const os = require('os');

const PROJECT_ID = 'cineflix-d573a';
const FIRESTORE_BASE_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/movies`;

const movies = [
  {
    id: 'neon-city',
    fields: {
      title: { stringValue: 'Neon City' },
      description: { stringValue: 'In a city ruled by algorithms, a young hacker discovers a hidden signal that could change everything.' },
      posterUrl: { stringValue: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=600&q=80' },
      backdropUrl: { stringValue: 'https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=1200&q=80' },
      videoUrl: { stringValue: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4' },
      genre: { stringValue: 'Sci-Fi / Thriller' },
      year: { integerValue: 2026 },
      duration: { integerValue: 118 },
      category: { stringValue: 'Trending' },
      isFeatured: { booleanValue: true }
    }
  },
  {
    id: 'the-last-signal',
    fields: {
      title: { stringValue: 'The Last Signal' },
      description: { stringValue: "After the world's communication network goes silent, an engineer races to discover who sent the final transmission." },
      posterUrl: { stringValue: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80' },
      backdropUrl: { stringValue: 'https://images.unsplash.com/photo-1447433589675-4aaa569f3e05?auto=format&fit=crop&w=1200&q=80' },
      videoUrl: { stringValue: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4' },
      genre: { stringValue: 'Mystery / Sci-Fi' },
      year: { integerValue: 2025 },
      duration: { integerValue: 124 },
      category: { stringValue: 'Popular' },
      isFeatured: { booleanValue: true }
    }
  },
  {
    id: 'beyond-earth',
    fields: {
      title: { stringValue: 'Beyond Earth' },
      description: { stringValue: "A deep-space expedition discovers something that challenges humanity's understanding of life." },
      posterUrl: { stringValue: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=600&q=80' },
      backdropUrl: { stringValue: 'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?auto=format&fit=crop&w=1200&q=80' },
      videoUrl: { stringValue: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4' },
      genre: { stringValue: 'Sci-Fi / Adventure' },
      year: { integerValue: 2026 },
      duration: { integerValue: 132 },
      category: { stringValue: 'New Releases' },
      isFeatured: { booleanValue: false }
    }
  },
  {
    id: 'midnight-run',
    fields: {
      title: { stringValue: 'Midnight Run' },
      description: { stringValue: 'One night. One package. One city hunting the courier who knows too much.' },
      posterUrl: { stringValue: 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?auto=format&fit=crop&w=600&q=80' },
      backdropUrl: { stringValue: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=1200&q=80' },
      videoUrl: { stringValue: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4' },
      genre: { stringValue: 'Action / Thriller' },
      year: { integerValue: 2025 },
      duration: { integerValue: 109 },
      category: { stringValue: 'Trending' },
      isFeatured: { booleanValue: false }
    }
  },
  {
    id: 'code-zero',
    fields: {
      title: { stringValue: 'Code Zero' },
      description: { stringValue: 'A cybersecurity analyst discovers a program capable of predicting crimes before they happen.' },
      posterUrl: { stringValue: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80' },
      backdropUrl: { stringValue: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=1200&q=80' },
      videoUrl: { stringValue: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4' },
      genre: { stringValue: 'Techno-Thriller' },
      year: { integerValue: 2026 },
      duration: { integerValue: 116 },
      category: { stringValue: 'Popular' },
      isFeatured: { booleanValue: false }
    }
  },
  {
    id: 'echoes',
    fields: {
      title: { stringValue: 'Echoes' },
      description: { stringValue: 'A filmmaker returns to his hometown and uncovers recordings connected to a decades-old mystery.' },
      posterUrl: { stringValue: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=600&q=80' },
      backdropUrl: { stringValue: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?auto=format&fit=crop&w=1200&q=80' },
      videoUrl: { stringValue: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4' },
      genre: { stringValue: 'Drama / Mystery' },
      year: { integerValue: 2024 },
      duration: { integerValue: 105 },
      category: { stringValue: 'Popular' },
      isFeatured: { booleanValue: false }
    }
  },
  {
    id: 'forgotten-planet',
    fields: {
      title: { stringValue: 'The Forgotten Planet' },
      description: { stringValue: 'An abandoned colony sends a distress signal years after it was declared lost.' },
      posterUrl: { stringValue: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&w=600&q=80' },
      backdropUrl: { stringValue: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?auto=format&fit=crop&w=1200&q=80' },
      videoUrl: { stringValue: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4' },
      genre: { stringValue: 'Sci-Fi / Adventure' },
      year: { integerValue: 2025 },
      duration: { integerValue: 127 },
      category: { stringValue: 'New Releases' },
      isFeatured: { booleanValue: false }
    }
  },
  {
    id: 'dark-horizon',
    fields: {
      title: { stringValue: 'Dark Horizon' },
      description: { stringValue: 'When an unexplained object appears beyond the moon, humanity faces an impossible decision.' },
      posterUrl: { stringValue: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?auto=format&fit=crop&w=600&q=80' },
      backdropUrl: { stringValue: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=80' },
      videoUrl: { stringValue: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4' },
      genre: { stringValue: 'Sci-Fi / Thriller' },
      year: { integerValue: 2026 },
      duration: { integerValue: 121 },
      category: { stringValue: 'Trending' },
      isFeatured: { booleanValue: false }
    }
  },
  {
    id: 'parallel',
    fields: {
      title: { stringValue: 'Parallel' },
      description: { stringValue: 'A student discovers a version of himself living a completely different life in a parallel world.' },
      posterUrl: { stringValue: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=600&q=80' },
      backdropUrl: { stringValue: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=1200&q=80' },
      videoUrl: { stringValue: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4' },
      genre: { stringValue: 'Sci-Fi / Drama' },
      year: { integerValue: 2025 },
      duration: { integerValue: 112 },
      category: { stringValue: 'New Releases' },
      isFeatured: { booleanValue: false }
    }
  },
  {
    id: 'final-protocol',
    fields: {
      title: { stringValue: 'Final Protocol' },
      description: { stringValue: 'An AI security system activates a protocol that its creators never intended to use.' },
      posterUrl: { stringValue: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=600&q=80' },
      backdropUrl: { stringValue: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=1200&q=80' },
      videoUrl: { stringValue: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4' },
      genre: { stringValue: 'Action / Sci-Fi' },
      year: { integerValue: 2026 },
      duration: { integerValue: 119 },
      category: { stringValue: 'Popular' },
      isFeatured: { booleanValue: false }
    }
  }
];

function getAccessTokenFromConfig() {
  const configPath = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
  if (!fs.existsSync(configPath)) {
    throw new Error('Firebase CLI configuration not found. Please log in using Firebase CLI: firebase login');
  }
  
  let config;
  try {
    config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  } catch (err) {
    throw new Error('Unable to parse Firebase CLI configuration. Please re-authenticate: firebase login:reauth');
  }

  const token = config?.tokens?.access_token;
  if (!token) {
    throw new Error('Firebase access token missing. Please authenticate using Firebase CLI: firebase login');
  }
  return token;
}

async function seed() {
  console.log('Reading Firebase CLI credentials from local environment...');
  const token = getAccessTokenFromConfig();

  // Test token with a light GET request to Firestore endpoint
  const testRes = await fetch(`https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`, {
    headers: { Authorization: `Bearer ${token}` }
  });

  if (testRes.status === 401) {
    throw new Error('Firebase CLI access token has expired. Please re-authenticate via CLI using: firebase login:reauth');
  }

  console.log('Firebase authentication verified. Seeding/Updating 10 demo movies...');

  for (const movie of movies) {
    const url = `${FIRESTORE_BASE_URL}/${movie.id}`;

    // Create or update document using PATCH with fields so it upserts idempotently
    const saveRes = await fetch(url, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ fields: movie.fields })
    });

    if (saveRes.ok) {
      console.log(`Successfully updated movie: '${movie.id}'`);
    } else {
      console.error(`Failed to update movie '${movie.id}' (Status ${saveRes.status}).`);
    }
  }
  console.log('Movie seeding/updating completed successfully.');
}

seed().catch(err => {
  console.error('Seeding process failed:', err.message);
  process.exit(1);
});
