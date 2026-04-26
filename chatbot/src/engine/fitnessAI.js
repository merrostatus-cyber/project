// ===== Fitify AI Response Engine =====
import { checkFitnessTopic, getRefusalMessage } from './topicFilter';
import { allExercises, getExercisesByMuscle, searchExercises } from './exercises';
import { generateWeeklyPlan, generateMuscleWorkout, generateQuickWorkout, generateHIIT } from './workoutPlans';

// ===== Intent Detection =====
function detectIntent(message) {
  const text = message.toLowerCase().trim();

  // Greeting
  if (/^(hi|hello|hey|howdy|sup|yo|what'?s?\s*up|good\s*(morning|afternoon|evening)|greetings|start|begin)/i.test(text)) {
    return { intent: 'greeting' };
  }
  if (/^(thanks?|thank\s*you|thx|appreciate)/i.test(text)) {
    return { intent: 'thanks' };
  }

  // Weekly plan request
  if (/\b(weekly|week)\s*(plan|program|routine|schedule|split)\b/i.test(text) ||
      /\b(plan|program|routine|schedule)\s*(for)?\s*(the)?\s*week\b/i.test(text) ||
      /\b(create|make|generate|give|build|design)\s*(me)?\s*(a)?\s*(workout|training|exercise|gym)?\s*(plan|program|routine|schedule)\b/i.test(text)) {
    const difficulty = extractDifficulty(text);
    const goal = extractGoal(text);
    const equipment = extractEquipment(text);
    const days = extractDays(text);
    return { intent: 'weekly_plan', difficulty, goal, equipment, daysAvailable: days };
  }

  // HIIT request
  if (/\bhiit\b/i.test(text) || /\b(high\s*intensity|interval\s*training|circuit\s*training)\b/i.test(text)) {
    return { intent: 'hiit', difficulty: extractDifficulty(text) };
  }

  // Quick workout
  if (/\b(quick|fast|short|(\d+)\s*min)/i.test(text) && /\b(workout|exercise|training|session)\b/i.test(text)) {
    const minutes = extractMinutes(text);
    return { intent: 'quick_workout', minutes, difficulty: extractDifficulty(text), equipment: extractEquipment(text) };
  }

  // Specific muscle group workout
  const muscleGroup = extractMuscleGroup(text);
  if (muscleGroup && /\b(workout|exercise|training|routine|day|hit|train|work|target)\b/i.test(text)) {
    return { intent: 'muscle_workout', muscleGroup, difficulty: extractDifficulty(text), equipment: extractEquipment(text) };
  }

  // Exercise explanation
  if (/\b(how\s*to|explain|what\s*is|form|technique|proper|correct)\b/i.test(text)) {
    const exercise = findExercise(text);
    if (exercise) return { intent: 'explain_exercise', exercise };
    if (muscleGroup) return { intent: 'muscle_workout', muscleGroup, difficulty: extractDifficulty(text) };
  }

  // Sets, reps, rest questions
  if (/\b(how\s*many|sets|reps|rest|weight|heavy|load)\b/i.test(text)) {
    return { intent: 'sets_reps_advice', difficulty: extractDifficulty(text), goal: extractGoal(text) };
  }

  // Rest day questions
  if (/\b(rest\s*day|recovery|off\s*day|overtraining|sore|soreness|doms)\b/i.test(text)) {
    return { intent: 'rest_day' };
  }

  // Goal-based questions
  const goal = extractGoal(text);
  if (goal) {
    return { intent: 'goal_advice', goal, difficulty: extractDifficulty(text) };
  }

  // Home workout
  if (/\b(home|no\s*gym|no\s*equipment|bodyweight|at\s*home)\b/i.test(text)) {
    return { intent: 'home_workout', difficulty: extractDifficulty(text) };
  }

  // Beginner help
  if (/\b(beginner|start|new\s*to|first\s*time|never\s*(worked|trained)|just\s*starting)\b/i.test(text)) {
    return { intent: 'beginner_help' };
  }

  // Muscle group mentioned without explicit workout request
  if (muscleGroup) {
    return { intent: 'muscle_workout', muscleGroup, difficulty: extractDifficulty(text) };
  }

  // Generic fitness question
  return { intent: 'general_fitness' };
}

// ===== Extractors =====
function extractDifficulty(text) {
  if (/\b(beginner|easy|starting|newbie|new)\b/i.test(text)) return 'beginner';
  if (/\b(intermediate|moderate|medium)\b/i.test(text)) return 'intermediate';
  if (/\b(advanced|hard|intense|expert|pro|challenging)\b/i.test(text)) return 'advanced';
  return null;
}

function extractGoal(text) {
  if (/\b(lose\s*weight|weight\s*loss|fat\s*loss|burn\s*fat|lean|slim|cut|cutting|shed|drop\s*weight|lean\s*down)\b/i.test(text)) return 'lose_weight';
  if (/\b(gain\s*muscle|build\s*muscle|bulk|bulking|mass|hypertrophy|bigger|grow|size)\b/i.test(text)) return 'gain_muscle';
  if (/\b(tone|toning|definition|defined|fit|general|health|healthy|overall|stay\s*fit)\b/i.test(text)) return 'general_fitness';
  if (/\b(endurance|stamina|cardio\s*fitness|cardiovascular)\b/i.test(text)) return 'endurance';
  if (/\b(strength|strong|power|powerlifting)\b/i.test(text)) return 'strength';
  if (/\b(flexible|flexibility|mobility|stretch)\b/i.test(text)) return 'flexibility';
  return null;
}

function extractEquipment(text) {
  if (/\b(home|no\s*gym|no\s*equipment|bodyweight)\b/i.test(text)) return 'bodyweight';
  if (/\b(dumbbell|dumbbells|db)\b/i.test(text)) return 'dumbbells';
  if (/\b(barbell|bar)\b/i.test(text)) return 'barbell';
  if (/\b(machine|cable|gym)\b/i.test(text)) return 'machine';
  if (/\b(resistance\s*band|band)\b/i.test(text)) return 'resistance band';
  return null;
}

function extractMuscleGroup(text) {
  if (/\b(chest|pec|pecs|pectoral)\b/i.test(text)) return 'chest';
  if (/\b(back|lat|lats|rear|pull)\b/i.test(text)) return 'back';
  if (/\b(leg|legs|quad|quads|hamstring|glute|glutes|thigh|calf|calves|squat)\b/i.test(text)) return 'legs';
  if (/\b(shoulder|shoulders|delt|delts|deltoid)\b/i.test(text)) return 'shoulders';
  if (/\b(arm|arms|bicep|biceps|tricep|triceps|forearm)\b/i.test(text)) return 'arms';
  if (/\b(core|abs|abdominal|oblique|six\s*pack|stomach)\b/i.test(text)) return 'core';
  return null;
}

function extractMinutes(text) {
  const match = text.match(/(\d+)\s*min/i);
  if (match) return parseInt(match[1], 10);
  if (/\b(quick|short|fast)\b/i.test(text)) return 15;
  return 20;
}

function findExercise(text) {
  const results = searchExercises(text);
  if (results.length > 0) {
    // Try to find the best match
    const textLower = text.toLowerCase();
    const exact = results.find(ex => textLower.includes(ex.name.toLowerCase()));
    return exact || results[0];
  }
  return null;
}

// ===== Response Generators =====
function generateGreetingResponse() {
  const greetings = [
    "Hey there, champ! 💪 I'm **Fitify**, your personal fitness coach!\n\nI'm here to help you with:\n• 🏋️ Custom workout plans\n• 💪 Exercise explanations with proper form\n• 📋 Beginner to advanced programs\n• 🎯 Muscle-group targeting\n• ⏱️ Quick workouts\n\nTo get started, tell me:\n1. What's your **fitness goal**? (lose weight / build muscle / stay fit)\n2. What's your **experience level**? (beginner / intermediate / advanced)\n3. What **equipment** do you have? (gym / home / dumbbells only)\n\nOr just ask me anything about fitness! 🔥",
    "Welcome to **Fitify**! 🏆 I'm your AI fitness coach, ready to help you crush your goals!\n\nI can help with:\n• Workout plans (home or gym)\n• Exercise form & technique\n• Weekly training schedules\n• Sets, reps, and rest advice\n\n**What would you like to work on today?** 💪",
  ];
  return { text: greetings[Math.floor(Math.random() * greetings.length)], type: 'text' };
}

function generateThanksResponse() {
  const responses = [
    "You're welcome! 💪 Keep pushing — consistency is key! Need anything else for your training?",
    "Happy to help! 🏆 Remember, every workout counts. Let me know if you need another plan or exercise tips!",
    "Anytime! 🔥 Stay dedicated and the results will come. What else can I help you with?",
  ];
  return { text: responses[Math.floor(Math.random() * responses.length)], type: 'text' };
}

function generateWeeklyPlanResponse(options) {
  const plan = generateWeeklyPlan(options);
  return { text: '', type: 'weekly_plan', data: plan };
}

function generateMuscleWorkoutResponse(muscleGroup, options) {
  const workout = generateMuscleWorkout(muscleGroup, options);
  return { text: '', type: 'muscle_workout', data: workout };
}

function generateExerciseExplanation(exercise) {
  let text = `### ${exercise.name}\n\n`;
  text += `**Target:** ${exercise.muscle}`;
  if (exercise.secondary && exercise.secondary.length > 0) {
    text += ` | **Secondary:** ${exercise.secondary.join(', ')}`;
  }
  text += `\n**Equipment:** ${exercise.equipment} | **Difficulty:** ${exercise.difficulty}\n`;
  text += `**Recommended:** ${exercise.sets} sets × ${exercise.reps} | Rest: ${exercise.rest}\n\n`;
  text += `**Step-by-step instructions:**\n`;
  exercise.instructions.forEach((step, i) => {
    text += `${i + 1}. ${step}\n`;
  });
  text += `\n💡 **Pro tip:** Focus on controlled movement and proper form over heavy weight. Quality reps beat quantity every time!`;
  return { text, type: 'text' };
}

function generateSetsRepsAdvice(difficulty, goal) {
  let text = "### Sets, Reps & Rest Guide 📊\n\n";

  if (goal === 'gain_muscle' || goal === 'strength') {
    text += "**For Muscle Growth (Hypertrophy):**\n";
    text += "• **Sets:** 3-4 per exercise\n";
    text += "• **Reps:** 8-12 (moderate weight)\n";
    text += "• **Rest:** 60-90 seconds between sets\n";
    text += "• **Tempo:** 2 seconds down, 1 second up\n\n";
    text += "**For Strength:**\n";
    text += "• **Sets:** 4-5 per exercise\n";
    text += "• **Reps:** 3-6 (heavy weight)\n";
    text += "• **Rest:** 2-3 minutes between sets\n";
  } else if (goal === 'lose_weight') {
    text += "**For Fat Loss:**\n";
    text += "• **Sets:** 3-4 per exercise\n";
    text += "• **Reps:** 12-15 (moderate weight)\n";
    text += "• **Rest:** 30-45 seconds (keep heart rate up!)\n";
    text += "• **Consider:** Supersets and circuit training\n";
  } else {
    text += "**General Guidelines by Goal:**\n\n";
    text += "| Goal | Sets | Reps | Rest | Weight |\n";
    text += "|------|------|------|------|--------|\n";
    text += "| Strength | 4-5 | 3-6 | 2-3 min | Heavy |\n";
    text += "| Muscle Size | 3-4 | 8-12 | 60-90s | Moderate |\n";
    text += "| Endurance | 2-3 | 15-20 | 30-45s | Light |\n";
    text += "| Fat Loss | 3-4 | 12-15 | 30-45s | Moderate |\n";
  }

  text += "\n\n💡 **Key principle:** Progressive overload — gradually increase weight, reps, or sets over time!";
  return { text, type: 'text' };
}

function generateRestDayAdvice() {
  const text = `### Rest & Recovery Guide 😴\n\n**Why rest days matter:**\nMuscles grow during rest, NOT during training. Skipping rest leads to overtraining, injury, and burnout.\n\n**Recommended rest schedule:**\n• **Beginners:** 2-3 rest days per week\n• **Intermediate:** 1-2 rest days per week\n• **Advanced:** 1 rest day per week (with active recovery)\n\n**Signs you need a rest day:**\n• Persistent muscle soreness (>72 hours)\n• Decreased performance\n• Feeling tired or unmotivated\n• Poor sleep quality\n• Increased resting heart rate\n\n**Active recovery ideas:**\n• Light walking (20-30 min)\n• Gentle yoga or stretching\n• Foam rolling\n• Swimming\n\n**Recovery tips:**\n• Sleep 7-9 hours per night 💤\n• Eat enough protein (0.7-1g per pound of body weight)\n• Stay hydrated (2-3 liters of water daily) 💧\n• Don't train the same muscle group on consecutive days\n\nRemember: **Rest is part of the program**, not a sign of weakness! 💪`;
  return { text, type: 'text' };
}

function generateGoalAdvice(goal) {
  const goalAdvice = {
    lose_weight: `### Fat Loss Strategy 🔥\n\n**Training approach:**\n• Combine resistance training + cardio\n• Train 4-5 days per week\n• Include 2-3 HIIT sessions per week\n• Full body or upper/lower split works best\n\n**Exercise priorities:**\n• Compound movements (squats, deadlifts, bench press, rows)\n• Circuit training to keep heart rate elevated\n• 12-15 reps with moderate weight and short rest\n\n**Key numbers:**\n• Calorie deficit of 300-500 kcal/day\n• Protein: 1g per lb of body weight (preserve muscle)\n• Cardio: 150-200 min per week total\n\n**Pro tips:**\n• Don't crash diet — slow and steady wins\n• Strength train to preserve muscle while losing fat\n• Track your food intake for best results\n• Stay patient — healthy fat loss is 0.5-1 lb/week\n\nWant me to create a specific workout plan for fat loss? 💪`,

    gain_muscle: `### Muscle Building Strategy 💪\n\n**Training approach:**\n• Train 4-6 days per week\n• Focus on progressive overload\n• PPL or upper/lower split recommended\n• Emphasize compound lifts + isolation work\n\n**Exercise priorities:**\n• Heavy compound lifts (squat, bench, deadlift, OHP, rows)\n• 8-12 reps for hypertrophy\n• 3-4 sets per exercise\n• Rest 60-90 seconds between sets\n\n**Key numbers:**\n• Calorie surplus of 200-300 kcal/day\n• Protein: 0.8-1.2g per lb of body weight\n• Sleep: 8+ hours for optimal recovery\n\n**Pro tips:**\n• Track your lifts — aim to increase weight or reps weekly\n• Don't neglect legs!\n• Mind-muscle connection matters\n• Eat enough — you can't build muscle in a deficit\n\nWant me to generate a muscle-building plan? 🏋️`,

    general_fitness: `### General Fitness Guide 🏆\n\n**Balanced approach:**\n• Train 3-4 days per week\n• Mix strength training + cardio\n• Include flexibility work\n• Full body routine works great\n\n**Weekly structure example:**\n• Mon: Full body strength\n• Wed: Cardio + core\n• Fri: Full body strength\n• Sat: Active recovery (yoga, walk)\n\n**Focus on:**\n• Compound movements for efficiency\n• 3 sets of 10-12 reps\n• 2-3 cardio sessions (20-30 min)\n• Stretching after every workout\n\nWant me to create a custom weekly plan? 📋`,

    endurance: `### Endurance Training Guide 🏃\n\n**Training approach:**\n• Mix cardio + muscular endurance work\n• Higher reps (15-20) with lighter weight\n• Short rest periods (30-45s)\n• Progressive cardio volume\n\n**Weekly structure:**\n• 3 days of cardio (run, cycle, swim)\n• 2 days of circuit/resistance training\n• 2 rest or active recovery days\n\n**Progression:**\n• Increase cardio duration by 10% per week\n• Add intervals for improved VO2 max\n• Include tempo work for sustained effort\n\nWant a detailed endurance program? 🔥`,

    strength: `### Strength Training Guide 🏋️\n\n**Training approach:**\n• Train 3-4 days per week\n• Focus on the big lifts\n• Low reps (3-6) with heavy weight\n• Long rest periods (2-5 minutes)\n\n**Key exercises:**\n• Squat, Bench Press, Deadlift, Overhead Press, Barbell Row\n• These compound movements build total-body strength\n\n**Programming:**\n• 4-5 sets of 3-6 reps\n• Increase weight by 2.5-5 lbs per session\n• Deload every 4-6 weeks\n• Track every lift in a training log\n\nWant me to create a strength-focused program? 💪`,

    flexibility: `### Flexibility & Mobility Guide 🧘\n\n**Daily routine (15-20 min):**\n• Dynamic stretching before workouts\n• Static stretching after workouts (hold 30-60s)\n• Foam rolling for tight areas\n\n**Key stretches:**\n• Hip flexor stretch (sitting all day tightens these)\n• Hamstring stretch\n• Chest/shoulder opener\n• Cat-cow for spinal mobility\n• Pigeon pose for hip flexibility\n\n**Tips:**\n• Never stretch cold muscles\n• Breathe deeply during stretches\n• Consistency > intensity\n• Yoga 2-3× per week transforms flexibility\n\nWant specific stretching routines? 🧘`,
  };

  return { text: goalAdvice[goal] || goalAdvice.general_fitness, type: 'text' };
}

function generateHomeWorkoutResponse(difficulty) {
  const workout = generateMuscleWorkout('chest', { equipment: 'bodyweight', difficulty });
  const quickPlan = generateQuickWorkout(30, { equipment: 'bodyweight', difficulty });

  let text = `### Home Workout (No Equipment Needed!) 🏠\n\n`;
  text += `Here's a **30-minute bodyweight workout** you can do anywhere:\n\n`;

  quickPlan.exercises.forEach((ex, i) => {
    text += `**${i + 1}. ${ex.name}**\n`;
    text += `   ${ex.sets} sets × ${ex.reps} | Rest: ${ex.rest}\n`;
    text += `   _Target: ${ex.muscle}_\n\n`;
  });

  text += `\n📝 **Notes:** ${quickPlan.notes}\n\n`;
  text += `💡 Want a full weekly home workout plan? Just ask! Or specify a muscle group like "home chest workout" 💪`;

  return { text, type: 'text' };
}

function generateBeginnerResponse() {
  const text = `### Welcome to Fitness! Here's Your Starter Guide 🌟\n\n**Congratulations on taking the first step!** Here's everything you need to know:\n\n**Week 1-2: Build the habit**\n• Start with 3 days per week\n• 20-30 minute sessions\n• Focus on learning proper form\n• Don't worry about weight — bodyweight is fine!\n\n**Essential exercises to learn:**\n1. **Squats** — King of leg exercises\n2. **Push-Ups** — Build upper body foundation\n3. **Planks** — Core stability essential\n4. **Lunges** — Balance and leg strength\n5. **Rows** — Back strength (use a table or low bar)\n\n**Beginner tips:**\n• ✅ Warm up 5 min before every workout\n• ✅ Start lighter than you think you need\n• ✅ Focus on form over everything\n• ✅ Rest 2-3 days per week\n• ✅ Stay hydrated and get enough sleep\n• ❌ Don't compare yourself to others\n• ❌ Don't skip warm-ups\n• ❌ Don't train through sharp pain\n\n**What's your goal?** Tell me and I'll create a personalized beginner plan! 🎯\n\nOptions:\n• 🔥 Lose weight\n• 💪 Build muscle\n• 🏃 Get fit & healthy\n• 🏠 Home workouts only`;

  return { text, type: 'text' };
}

function generateHIITResponse(difficulty) {
  const hiit = generateHIIT(difficulty || 'intermediate');
  return { text: '', type: 'hiit', data: hiit };
}

function generateQuickWorkoutResponse(minutes, options) {
  const workout = generateQuickWorkout(minutes, options);

  let text = `### ⚡ Quick ${minutes}-Minute Workout\n\n`;
  workout.exercises.forEach((ex, i) => {
    text += `**${i + 1}. ${ex.name}**\n`;
    text += `   ${ex.sets} sets × ${ex.reps} | Rest: ${ex.rest}\n`;
    text += `   _Target: ${ex.muscle}_ | _${ex.equipment}_\n\n`;
  });
  text += `\n📝 ${workout.notes}`;

  return { text, type: 'text' };
}

function generateGeneralResponse() {
  const responses = [
    "I'd love to help! Could you be more specific? For example:\n\n• **\"Give me a chest workout\"** — targeted muscle training\n• **\"Create a weekly plan\"** — full program\n• **\"How to do push-ups\"** — exercise form guide\n• **\"Beginner workout\"** — starter program\n• **\"15 min HIIT\"** — quick intense session\n\nWhat are you looking for? 💪",
    "I'm ready to help with your fitness journey! 🏋️ Here are some things you can ask:\n\n• Workout plans for any goal\n• Exercise explanations\n• Sets, reps, and rest advice\n• Muscle group targeting\n• Home or gym workouts\n\nWhat would you like to know? 🔥",
  ];
  return { text: responses[Math.floor(Math.random() * responses.length)], type: 'text' };
}

// ===== Main Response Function =====
export function generateResponse(message, conversationHistory = []) {
  // Check if the message is fitness-related
  const topicCheck = checkFitnessTopic(message);

  if (!topicCheck.isFitness) {
    return { text: getRefusalMessage(), type: 'text' };
  }

  // Detect intent
  const intent = detectIntent(message);

  switch (intent.intent) {
    case 'greeting':
      return generateGreetingResponse();

    case 'thanks':
      return generateThanksResponse();

    case 'weekly_plan':
      return generateWeeklyPlanResponse({
        difficulty: intent.difficulty,
        goal: intent.goal,
        equipment: intent.equipment,
        daysAvailable: intent.daysAvailable,
      });

    case 'hiit':
      return generateHIITResponse(intent.difficulty);

    case 'quick_workout':
      return generateQuickWorkoutResponse(intent.minutes, {
        difficulty: intent.difficulty,
        equipment: intent.equipment,
      });

    case 'muscle_workout':
      return generateMuscleWorkoutResponse(intent.muscleGroup, {
        difficulty: intent.difficulty,
        equipment: intent.equipment,
      });

    case 'explain_exercise':
      return generateExerciseExplanation(intent.exercise);

    case 'sets_reps_advice':
      return generateSetsRepsAdvice(intent.difficulty, intent.goal);

    case 'rest_day':
      return generateRestDayAdvice();

    case 'goal_advice':
      return generateGoalAdvice(intent.goal);

    case 'home_workout':
      return generateHomeWorkoutResponse(intent.difficulty);

    case 'beginner_help':
      return generateBeginnerResponse();

    case 'general_fitness':
    default:
      return generateGeneralResponse();
  }
}

export default { generateResponse };
