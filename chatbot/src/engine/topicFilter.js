// ===== Fitness Topic Filter =====
// Ensures the chatbot ONLY responds to fitness-related topics

const fitnessKeywords = [
  // General fitness
  'workout', 'exercise', 'training', 'fitness', 'gym', 'muscle', 'strength',
  'cardio', 'hiit', 'stretch', 'warm up', 'cool down', 'recovery', 'rest day',
  'progressive overload', 'superset', 'drop set', 'circuit',

  // Body parts
  'chest', 'back', 'legs', 'shoulders', 'arms', 'biceps', 'triceps', 'abs',
  'core', 'glutes', 'quads', 'hamstrings', 'calves', 'forearms', 'traps',
  'delts', 'lats', 'pecs', 'obliques', 'upper body', 'lower body',

  // Exercises
  'push up', 'pushup', 'pull up', 'pullup', 'squat', 'deadlift', 'bench press',
  'lunge', 'plank', 'crunch', 'burpee', 'curl', 'press', 'row', 'fly', 'flye',
  'dip', 'sit up', 'situp', 'mountain climber', 'jump', 'running', 'jogging',
  'walking', 'swimming', 'cycling', 'yoga', 'pilates', 'calisthenics',
  'kettlebell', 'dumbbell', 'barbell', 'resistance band',

  // Goals
  'lose weight', 'weight loss', 'fat loss', 'burn fat', 'lean', 'cut', 'cutting',
  'gain muscle', 'build muscle', 'bulk', 'bulking', 'tone', 'toning',
  'endurance', 'flexibility', 'mobility', 'posture', 'body composition',
  'six pack', 'flat stomach',

  // Equipment
  'equipment', 'home workout', 'bodyweight', 'gym equipment', 'machine',
  'dumbbell', 'barbell', 'bench', 'pull up bar', 'treadmill', 'elliptical',
  'resistance band', 'foam roller', 'medicine ball', 'cable',

  // Training concepts
  'rep', 'reps', 'set', 'sets', 'form', 'technique', 'beginner', 'intermediate',
  'advanced', 'program', 'plan', 'routine', 'schedule', 'split', 'ppl',
  'push pull', 'full body', 'body part',

  // Health/nutrition (fitness-adjacent)
  'protein', 'calories', 'bmi', 'body fat', 'nutrition', 'diet', 'supplement',
  'creatine', 'whey', 'pre workout', 'post workout', 'meal', 'hydration',
  'water intake', 'macros', 'carbs', 'healthy',

  // Misc fitness
  'sore', 'soreness', 'doms', 'injury', 'pain', 'prevent', 'motivation',
  'progress', 'plateau', 'overtraining', 'deload', 'personal trainer',
  'coach', 'athlete', 'bodybuilding', 'powerlifting', 'crossfit', 'sport',
  'warmup', 'cooldown', 'stretching', 'physical',
];

// Greeting patterns
const greetingPatterns = [
  /^(hi|hello|hey|howdy|good\s*(morning|afternoon|evening)|what'?s?\s*up|yo|sup|greetings)/i,
  /^(start|begin|help|assist)/i,
  /^(thank|thanks|thx)/i,
];

// Non-fitness topics to explicitly reject
const nonFitnessPatterns = [
  /\b(politics|president|election|government|democrat|republican|vote)\b/i,
  /\b(movie|film|netflix|tv show|celebrity|actor|actress|singer)\b/i,
  /\b(recipe|cook|bake|kitchen)\b/i,
  /\b(code|program|javascript|python|html|css|api|database|software|bug|deploy)\b/i,
  /\b(math|algebra|calculus|equation|geometry|physics|chemistry|biology)\b/i,
  /\b(weather|forecast|temperature|rain|sunny)\b/i,
  /\b(stock|invest|crypto|bitcoin|money|bank|finance|loan)\b/i,
  /\b(game|gaming|playstation|xbox|nintendo|fortnite|minecraft)\b/i,
  /\b(relationship|dating|love|breakup|marriage)\b/i,
  /\b(news|war|conflict|scandal)\b/i,
  /\b(poem|poetry|story|novel|book|literature)\b/i,
  /\b(travel|flight|hotel|vacation|tourism)\b/i,
  /\b(cat|dog|pet|animal)\b/i,
  /\b(joke|funny|humor|meme)\b/i,
];

/**
 * Check if a message is fitness-related
 * @param {string} message - User's message
 * @returns {{ isFitness: boolean, isGreeting: boolean, confidence: number }}
 */
export function checkFitnessTopic(message) {
  const text = message.toLowerCase().trim();

  // Check for greetings first
  for (const pattern of greetingPatterns) {
    if (pattern.test(text)) {
      return { isFitness: true, isGreeting: true, confidence: 1.0 };
    }
  }

  // Check for explicit non-fitness topics
  for (const pattern of nonFitnessPatterns) {
    if (pattern.test(text)) {
      return { isFitness: false, isGreeting: false, confidence: 0.9 };
    }
  }

  // Check for fitness keywords
  let matchCount = 0;
  for (const keyword of fitnessKeywords) {
    if (text.includes(keyword)) {
      matchCount++;
    }
  }

  // If message is very short and has no fitness keywords, might be ambiguous
  const wordCount = text.split(/\s+/).length;

  if (matchCount > 0) {
    const confidence = Math.min(0.5 + matchCount * 0.15, 1.0);
    return { isFitness: true, isGreeting: false, confidence };
  }

  // Very short messages might be follow-ups (allow them)
  if (wordCount <= 3) {
    return { isFitness: true, isGreeting: false, confidence: 0.4 };
  }

  // Default: not fitness related
  return { isFitness: false, isGreeting: false, confidence: 0.3 };
}

/**
 * Get a polite refusal message
 */
export function getRefusalMessage() {
  const refusals = [
    "I'm **Fitify**, your dedicated fitness coach! 💪 I can only help with workouts, training, and fitness topics.\n\nTry asking me about:\n• 🏋️ Workout plans (home or gym)\n• 💪 Specific muscle exercises\n• 📋 Beginner to advanced programs\n• 🎯 Weight loss or muscle gain tips\n• ⏱️ Quick workout sessions",
    "Oops! That's outside my area of expertise. I'm all about **fitness and training** 🏆\n\nHere's what I can help with:\n• Custom workout plans\n• Exercise explanations\n• Muscle targeting advice\n• Training schedules\n• Sets, reps, and rest recommendations",
    "I appreciate the question, but I'm a **fitness-only** assistant! 🎯\n\nLet me help you with what I know best:\n• 🔥 HIIT workouts\n• 🏠 Home exercise routines\n• 💪 Muscle building programs\n• 📉 Fat loss strategies\n• 🧘 Flexibility & mobility",
  ];
  return refusals[Math.floor(Math.random() * refusals.length)];
}

export default { checkFitnessTopic, getRefusalMessage };
