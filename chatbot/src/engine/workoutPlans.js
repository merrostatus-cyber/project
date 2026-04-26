// ===== Workout Plan Generator =====
import { getExercisesByMuscle, getExercisesByDifficulty, getExercisesByEquipment, allExercises } from './exercises';

// Pick N random items from an array
function pickRandom(arr, n) {
  const shuffled = [...arr].sort(() => 0.5 - Math.random());
  return shuffled.slice(0, Math.min(n, arr.length));
}

// Filter exercises based on criteria
function filterExercises(options = {}) {
  let pool = [...allExercises];

  if (options.difficulty) {
    pool = pool.filter(ex => ex.difficulty === options.difficulty);
  }
  if (options.equipment) {
    const eq = options.equipment.toLowerCase();
    if (eq === 'bodyweight' || eq === 'home' || eq === 'none') {
      pool = pool.filter(ex => ex.equipment === 'Bodyweight');
    } else {
      pool = pool.filter(ex =>
        ex.equipment.toLowerCase().includes(eq) || ex.equipment === 'Bodyweight'
      );
    }
  }
  if (options.muscleGroup) {
    pool = pool.filter(ex => ex.muscleGroup === options.muscleGroup.toLowerCase());
  }

  return pool;
}

// ===== Plan Templates =====
const planTemplates = {
  // Full Body (3 days) - great for beginners
  fullBody: {
    name: "Full Body Program",
    daysPerWeek: 3,
    schedule: [
      { day: "Day 1 (Mon)", label: "Full Body A", muscles: ["chest", "back", "legs", "core"] },
      { day: "Day 2 (Wed)", label: "Full Body B", muscles: ["shoulders", "arms", "legs", "core"] },
      { day: "Day 3 (Fri)", label: "Full Body C", muscles: ["chest", "back", "shoulders", "core"] },
    ],
    restDays: ["Tuesday", "Thursday", "Saturday", "Sunday"],
  },

  // Upper/Lower Split (4 days)
  upperLower: {
    name: "Upper/Lower Split",
    daysPerWeek: 4,
    schedule: [
      { day: "Day 1 (Mon)", label: "Upper Body", muscles: ["chest", "back", "shoulders", "arms"] },
      { day: "Day 2 (Tue)", label: "Lower Body", muscles: ["legs", "core"] },
      { day: "Day 3 (Thu)", label: "Upper Body", muscles: ["chest", "back", "shoulders", "arms"] },
      { day: "Day 4 (Fri)", label: "Lower Body", muscles: ["legs", "core"] },
    ],
    restDays: ["Wednesday", "Saturday", "Sunday"],
  },

  // Push/Pull/Legs (6 days) - intermediate/advanced
  ppl: {
    name: "Push/Pull/Legs (PPL)",
    daysPerWeek: 6,
    schedule: [
      { day: "Day 1 (Mon)", label: "Push", muscles: ["chest", "shoulders", "arms"] },
      { day: "Day 2 (Tue)", label: "Pull", muscles: ["back", "arms"] },
      { day: "Day 3 (Wed)", label: "Legs", muscles: ["legs", "core"] },
      { day: "Day 4 (Thu)", label: "Push", muscles: ["chest", "shoulders"] },
      { day: "Day 5 (Fri)", label: "Pull", muscles: ["back", "arms"] },
      { day: "Day 6 (Sat)", label: "Legs", muscles: ["legs", "core"] },
    ],
    restDays: ["Sunday"],
  },

  // Bro Split (5 days) - classic bodybuilding
  broSplit: {
    name: "Classic 5-Day Split",
    daysPerWeek: 5,
    schedule: [
      { day: "Day 1 (Mon)", label: "Chest Day", muscles: ["chest"] },
      { day: "Day 2 (Tue)", label: "Back Day", muscles: ["back"] },
      { day: "Day 3 (Wed)", label: "Shoulders & Arms", muscles: ["shoulders", "arms"] },
      { day: "Day 4 (Thu)", label: "Leg Day", muscles: ["legs"] },
      { day: "Day 5 (Fri)", label: "Core & Conditioning", muscles: ["core"] },
    ],
    restDays: ["Saturday", "Sunday"],
  },
};

// Generate a full weekly plan
export function generateWeeklyPlan(options = {}) {
  const { goal, difficulty, equipment, daysAvailable } = options;

  // Select template based on days available or difficulty
  let template;
  if (daysAvailable && daysAvailable <= 3) {
    template = planTemplates.fullBody;
  } else if (daysAvailable === 4) {
    template = planTemplates.upperLower;
  } else if (daysAvailable >= 5 && difficulty === 'advanced') {
    template = planTemplates.ppl;
  } else if (daysAvailable >= 5) {
    template = planTemplates.broSplit;
  } else if (difficulty === 'beginner') {
    template = planTemplates.fullBody;
  } else if (difficulty === 'advanced') {
    template = planTemplates.ppl;
  } else {
    template = planTemplates.upperLower;
  }

  // Build the plan
  const plan = {
    name: template.name,
    difficulty: difficulty || 'intermediate',
    goal: goal || 'general fitness',
    daysPerWeek: template.daysPerWeek,
    restDays: template.restDays,
    days: [],
  };

  template.schedule.forEach(day => {
    const dayPlan = {
      day: day.day,
      label: day.label,
      exercises: [],
    };

    day.muscles.forEach(muscle => {
      const pool = filterExercises({ muscleGroup: muscle, difficulty, equipment });
      const fallback = filterExercises({ muscleGroup: muscle });
      const source = pool.length >= 2 ? pool : fallback;
      const exercisesPerMuscle = day.muscles.length > 3 ? 1 : 2;
      const picked = pickRandom(source, exercisesPerMuscle);
      dayPlan.exercises.push(...picked);
    });

    plan.days.push(dayPlan);
  });

  return plan;
}

// Generate a single workout for a specific muscle group
export function generateMuscleWorkout(muscleGroup, options = {}) {
  const pool = filterExercises({ muscleGroup, ...options });
  const fallback = getExercisesByMuscle(muscleGroup);
  const source = pool.length >= 3 ? pool : fallback;
  const exercises = pickRandom(source, options.count || 5);

  return {
    muscleGroup,
    difficulty: options.difficulty || 'all levels',
    equipment: options.equipment || 'any',
    exercises,
    tips: getMuscleGroupTips(muscleGroup),
  };
}

// Generate a quick workout based on time available
export function generateQuickWorkout(minutes, options = {}) {
  const exerciseCount = Math.max(3, Math.floor(minutes / 5));
  const pool = filterExercises(options);
  const source = pool.length >= exerciseCount ? pool : allExercises;
  const exercises = pickRandom(source, exerciseCount);

  return {
    duration: `${minutes} minutes`,
    exercises,
    notes: minutes <= 15
      ? "Short but intense! Minimize rest between exercises."
      : minutes <= 30
      ? "Great workout length. Rest 45-60s between sets."
      : "Full workout session. Take adequate rest between heavy sets.",
  };
}

// Generate a HIIT session
export function generateHIIT(difficulty = 'intermediate') {
  const bodyweightExs = allExercises.filter(
    ex => ex.equipment === 'Bodyweight' &&
    (difficulty === 'beginner' ? ex.difficulty === 'beginner' : true)
  );
  const picked = pickRandom(bodyweightExs, 6);

  const workTime = difficulty === 'beginner' ? 20 : difficulty === 'advanced' ? 40 : 30;
  const restTime = difficulty === 'beginner' ? 40 : difficulty === 'advanced' ? 15 : 20;
  const rounds = difficulty === 'beginner' ? 2 : difficulty === 'advanced' ? 4 : 3;

  return {
    type: "HIIT Circuit",
    difficulty,
    format: `${workTime}s work / ${restTime}s rest × ${rounds} rounds`,
    totalTime: `~${Math.round((picked.length * (workTime + restTime) * rounds) / 60)} minutes`,
    exercises: picked.map(ex => ({ ...ex, reps: `${workTime}s` })),
    tips: [
      "Warm up for 5 minutes before starting",
      "Focus on form over speed",
      "Rest 1-2 minutes between rounds",
      "Cool down and stretch after finishing",
    ],
  };
}

// Get tips per muscle group
function getMuscleGroupTips(muscleGroup) {
  const tips = {
    chest: ["Always warm up shoulders before chest training", "Focus on the mind-muscle connection", "Don't bounce the bar off your chest on bench press"],
    back: ["Pull with your elbows, not your hands", "Squeeze your shoulder blades together at the top", "Use straps if grip is limiting your back training"],
    legs: ["Never skip leg day!", "Go deep on squats for full muscle activation", "Warm up knees with light leg extensions before heavy squats"],
    shoulders: ["Warm up rotator cuffs before pressing", "Don't use momentum on lateral raises", "Train all three delt heads for rounded shoulders"],
    arms: ["Don't swing the weight — control the movement", "Train both biceps and triceps for balanced development", "Triceps make up 2/3 of your arm size!"],
    core: ["Brace your core like you're about to be punched", "Avoid pulling on your neck during crunches", "Train core at the end of your workout"],
  };
  return tips[muscleGroup] || ["Focus on proper form", "Progressive overload is key", "Stay consistent!"];
}

export { planTemplates };
