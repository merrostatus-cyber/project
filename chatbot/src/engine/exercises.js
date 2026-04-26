// ===== Fitify Exercise Database =====
// 100+ exercises organized by muscle group, equipment, and difficulty

const exercises = {
  chest: [
    { name: "Push-Ups", muscle: "Chest", secondary: ["Triceps", "Shoulders"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "10-15", rest: "60s", instructions: ["Start in a high plank position with hands slightly wider than shoulder-width", "Lower your body until chest nearly touches the floor", "Keep your core tight and body in a straight line", "Push back up to the starting position", "Breathe in as you lower, breathe out as you push up"] },
    { name: "Incline Push-Ups", muscle: "Upper Chest", secondary: ["Shoulders", "Triceps"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "12-15", rest: "60s", instructions: ["Place hands on an elevated surface (bench, step, or sturdy chair)", "Lower chest toward the surface, keeping body straight", "Push back up to starting position"] },
    { name: "Diamond Push-Ups", muscle: "Inner Chest", secondary: ["Triceps"], equipment: "Bodyweight", difficulty: "intermediate", sets: 3, reps: "8-12", rest: "60s", instructions: ["Form a diamond shape with hands under your chest", "Lower body while keeping elbows at 45°", "Push back up, focus on chest squeeze at the top"] },
    { name: "Dumbbell Bench Press", muscle: "Chest", secondary: ["Triceps", "Shoulders"], equipment: "Dumbbells", difficulty: "intermediate", sets: 4, reps: "8-12", rest: "90s", instructions: ["Lie flat on a bench holding dumbbells above chest", "Lower dumbbells to chest level with controlled motion", "Press up, squeezing chest at the top", "Keep feet flat on the floor for stability"] },
    { name: "Dumbbell Flyes", muscle: "Chest", secondary: ["Shoulders"], equipment: "Dumbbells", difficulty: "intermediate", sets: 3, reps: "10-12", rest: "60s", instructions: ["Lie flat holding dumbbells with arms extended above chest", "Open arms wide in an arc motion, slight bend in elbows", "Feel the stretch in your chest, then squeeze back to start"] },
    { name: "Barbell Bench Press", muscle: "Chest", secondary: ["Triceps", "Shoulders"], equipment: "Barbell", difficulty: "intermediate", sets: 4, reps: "6-10", rest: "120s", instructions: ["Lie flat, grip bar slightly wider than shoulder-width", "Unrack and lower bar to mid-chest with control", "Press up explosively, locking out arms at the top", "Keep shoulder blades retracted throughout"] },
    { name: "Incline Dumbbell Press", muscle: "Upper Chest", secondary: ["Shoulders", "Triceps"], equipment: "Dumbbells", difficulty: "intermediate", sets: 4, reps: "8-12", rest: "90s", instructions: ["Set bench to 30-45° incline", "Press dumbbells up from shoulder level", "Lower with control, feel the stretch at the bottom"] },
    { name: "Cable Crossover", muscle: "Chest", secondary: ["Shoulders"], equipment: "Machine", difficulty: "intermediate", sets: 3, reps: "12-15", rest: "60s", instructions: ["Stand between cable stations with handles set high", "Step forward slightly, bring arms together in front", "Squeeze chest hard at the bottom, return slowly"] },
    { name: "Decline Push-Ups", muscle: "Upper Chest", secondary: ["Shoulders", "Triceps"], equipment: "Bodyweight", difficulty: "intermediate", sets: 3, reps: "10-15", rest: "60s", instructions: ["Place feet on elevated surface, hands on floor", "Lower chest toward floor", "Push up, keeping core tight throughout"] },
    { name: "Weighted Dips", muscle: "Lower Chest", secondary: ["Triceps", "Shoulders"], equipment: "Bodyweight", difficulty: "advanced", sets: 4, reps: "8-12", rest: "90s", instructions: ["Lean forward on parallel bars (chest focus)", "Lower body until arms are at 90° or below", "Push up with chest focus, avoid locking elbows abruptly"] },
  ],
  back: [
    { name: "Superman Hold", muscle: "Lower Back", secondary: ["Glutes"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "15-20", rest: "45s", instructions: ["Lie face down, arms extended overhead", "Lift arms, chest, and legs off the floor simultaneously", "Hold for 2-3 seconds, squeeze your lower back", "Lower and repeat"] },
    { name: "Inverted Rows", muscle: "Upper Back", secondary: ["Biceps", "Core"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "8-12", rest: "60s", instructions: ["Set a bar at waist height, hang underneath with feet forward", "Pull chest to the bar squeezing shoulder blades", "Lower with control"] },
    { name: "Dumbbell Rows", muscle: "Lats", secondary: ["Biceps", "Rear Delts"], equipment: "Dumbbells", difficulty: "intermediate", sets: 4, reps: "8-12", rest: "90s", instructions: ["Place one knee and hand on a bench for support", "Row dumbbell toward hip, squeezing the lat", "Lower with control, keeping back flat"] },
    { name: "Pull-Ups", muscle: "Lats", secondary: ["Biceps", "Rear Delts"], equipment: "Bodyweight", difficulty: "intermediate", sets: 4, reps: "6-10", rest: "90s", instructions: ["Hang from bar with overhand grip slightly wider than shoulders", "Pull yourself up until chin clears the bar", "Lower with control — no swinging!"] },
    { name: "Barbell Rows", muscle: "Upper Back", secondary: ["Biceps", "Lower Back"], equipment: "Barbell", difficulty: "intermediate", sets: 4, reps: "8-10", rest: "90s", instructions: ["Bend over with bar hanging at arm's length", "Pull bar toward lower chest/upper abs", "Squeeze shoulder blades, lower slowly"] },
    { name: "Lat Pulldown", muscle: "Lats", secondary: ["Biceps"], equipment: "Machine", difficulty: "beginner", sets: 3, reps: "10-12", rest: "60s", instructions: ["Sit at lat pulldown machine, grip bar wide", "Pull bar to upper chest, squeezing lats", "Return slowly with full stretch at top"] },
    { name: "Seated Cable Row", muscle: "Mid Back", secondary: ["Biceps", "Rear Delts"], equipment: "Machine", difficulty: "beginner", sets: 3, reps: "10-12", rest: "60s", instructions: ["Sit upright, pull handle to lower chest", "Squeeze shoulder blades together", "Extend arms fully on the return"] },
    { name: "Deadlift", muscle: "Full Back", secondary: ["Glutes", "Hamstrings", "Core"], equipment: "Barbell", difficulty: "advanced", sets: 4, reps: "5-8", rest: "180s", instructions: ["Stand with feet hip-width, bar over mid-foot", "Hinge at hips, grip bar just outside knees", "Drive through heels, keep back flat, stand up", "Lower with control by hinging at hips"] },
    { name: "T-Bar Row", muscle: "Mid Back", secondary: ["Biceps", "Lats"], equipment: "Barbell", difficulty: "intermediate", sets: 4, reps: "8-12", rest: "90s", instructions: ["Straddle the bar, grip handle close to plates", "Row bar toward chest, squeezing back muscles", "Lower with control"] },
    { name: "Face Pulls", muscle: "Rear Delts", secondary: ["Traps", "Rotator Cuff"], equipment: "Machine", difficulty: "beginner", sets: 3, reps: "15-20", rest: "45s", instructions: ["Set cable at face height with rope attachment", "Pull toward face, separating rope ends at ears", "Squeeze rear delts, return slowly"] },
  ],
  legs: [
    { name: "Bodyweight Squats", muscle: "Quads", secondary: ["Glutes", "Hamstrings"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "15-20", rest: "60s", instructions: ["Stand feet shoulder-width apart", "Lower by pushing hips back and bending knees", "Go as low as comfortable, thighs parallel or below", "Push through heels to stand up"] },
    { name: "Lunges", muscle: "Quads", secondary: ["Glutes", "Hamstrings"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "10 each leg", rest: "60s", instructions: ["Step forward into a lunge position", "Lower back knee toward the floor", "Push off front foot to return to standing", "Alternate legs each rep"] },
    { name: "Glute Bridges", muscle: "Glutes", secondary: ["Hamstrings", "Core"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "15-20", rest: "45s", instructions: ["Lie on back, knees bent, feet flat on floor", "Push hips up, squeezing glutes at the top", "Hold for 2 seconds, lower with control"] },
    { name: "Wall Sit", muscle: "Quads", secondary: ["Glutes"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "30-60 seconds", rest: "60s", instructions: ["Lean against a wall, slide down until thighs are parallel", "Hold position, keep back flat against the wall", "Push through heels for stability"] },
    { name: "Bulgarian Split Squat", muscle: "Quads", secondary: ["Glutes", "Hamstrings"], equipment: "Bodyweight", difficulty: "intermediate", sets: 3, reps: "10 each leg", rest: "60s", instructions: ["Place rear foot on a bench behind you", "Lower front knee to 90°, keeping torso upright", "Push up through front heel"] },
    { name: "Barbell Squats", muscle: "Quads", secondary: ["Glutes", "Hamstrings", "Core"], equipment: "Barbell", difficulty: "intermediate", sets: 4, reps: "6-10", rest: "120s", instructions: ["Bar on upper back, feet shoulder-width", "Squat down with control, thighs to parallel or below", "Drive up through heels, keep chest up"] },
    { name: "Romanian Deadlift", muscle: "Hamstrings", secondary: ["Glutes", "Lower Back"], equipment: "Dumbbells", difficulty: "intermediate", sets: 3, reps: "10-12", rest: "90s", instructions: ["Hold dumbbells in front of thighs", "Hinge at hips, slight knee bend", "Lower until you feel hamstring stretch", "Squeeze glutes to return to standing"] },
    { name: "Leg Press", muscle: "Quads", secondary: ["Glutes", "Hamstrings"], equipment: "Machine", difficulty: "beginner", sets: 4, reps: "10-12", rest: "90s", instructions: ["Sit in leg press, feet shoulder-width on platform", "Lower platform toward chest with control", "Press up without locking knees at the top"] },
    { name: "Calf Raises", muscle: "Calves", secondary: [], equipment: "Bodyweight", difficulty: "beginner", sets: 4, reps: "15-20", rest: "45s", instructions: ["Stand on edge of a step with heels hanging off", "Rise up on toes, squeeze calves at the top", "Lower slowly below step level for full stretch"] },
    { name: "Front Squats", muscle: "Quads", secondary: ["Core", "Glutes"], equipment: "Barbell", difficulty: "advanced", sets: 4, reps: "6-8", rest: "120s", instructions: ["Bar rests on front delts, elbows high", "Squat down keeping torso very upright", "Drive up through heels, maintaining elbow position"] },
  ],
  shoulders: [
    { name: "Pike Push-Ups", muscle: "Shoulders", secondary: ["Triceps"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "8-12", rest: "60s", instructions: ["Start in downward dog position, hands shoulder-width", "Bend elbows, lowering head toward the floor", "Push back up to starting position"] },
    { name: "Lateral Raises", muscle: "Side Delts", secondary: [], equipment: "Dumbbells", difficulty: "beginner", sets: 3, reps: "12-15", rest: "45s", instructions: ["Stand with dumbbells at sides", "Raise arms out to sides until parallel with floor", "Lower slowly with control, slight bend in elbows"] },
    { name: "Overhead Press", muscle: "Shoulders", secondary: ["Triceps", "Upper Chest"], equipment: "Dumbbells", difficulty: "intermediate", sets: 4, reps: "8-12", rest: "90s", instructions: ["Hold dumbbells at shoulder height, palms forward", "Press overhead until arms are fully extended", "Lower with control back to shoulders"] },
    { name: "Arnold Press", muscle: "Shoulders", secondary: ["Triceps"], equipment: "Dumbbells", difficulty: "intermediate", sets: 3, reps: "8-12", rest: "90s", instructions: ["Start with palms facing you at shoulder height", "Rotate palms forward as you press up", "Reverse the rotation as you lower back down"] },
    { name: "Front Raises", muscle: "Front Delts", secondary: [], equipment: "Dumbbells", difficulty: "beginner", sets: 3, reps: "12-15", rest: "45s", instructions: ["Stand with dumbbells in front of thighs", "Raise one or both arms in front to shoulder height", "Lower slowly, maintain slight elbow bend"] },
    { name: "Barbell Overhead Press", muscle: "Shoulders", secondary: ["Triceps", "Core"], equipment: "Barbell", difficulty: "intermediate", sets: 4, reps: "6-10", rest: "120s", instructions: ["Grip bar at shoulder width, bar on front delts", "Press overhead, slight lean back at the start", "Lock out at top, lower with control"] },
    { name: "Reverse Flyes", muscle: "Rear Delts", secondary: ["Upper Back"], equipment: "Dumbbells", difficulty: "beginner", sets: 3, reps: "12-15", rest: "45s", instructions: ["Bend over at hips, dumbbells hanging down", "Raise arms out to sides, squeezing rear delts", "Lower slowly"] },
    { name: "Handstand Push-Ups", muscle: "Shoulders", secondary: ["Triceps", "Core"], equipment: "Bodyweight", difficulty: "advanced", sets: 3, reps: "5-8", rest: "120s", instructions: ["Kick up into a handstand against a wall", "Lower head toward the floor by bending elbows", "Push back up to full handstand"] },
  ],
  arms: [
    { name: "Bicep Curls", muscle: "Biceps", secondary: ["Forearms"], equipment: "Dumbbells", difficulty: "beginner", sets: 3, reps: "10-12", rest: "60s", instructions: ["Stand holding dumbbells at sides, palms forward", "Curl weights toward shoulders, keeping elbows fixed", "Squeeze biceps at top, lower slowly"] },
    { name: "Hammer Curls", muscle: "Biceps", secondary: ["Brachialis", "Forearms"], equipment: "Dumbbells", difficulty: "beginner", sets: 3, reps: "10-12", rest: "60s", instructions: ["Hold dumbbells with neutral grip (palms facing body)", "Curl up without rotating wrists", "Lower with control"] },
    { name: "Tricep Dips", muscle: "Triceps", secondary: ["Chest", "Shoulders"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "8-12", rest: "60s", instructions: ["Grip edge of a bench or chair behind you", "Lower body by bending elbows to ~90°", "Push up, straightening arms completely"] },
    { name: "Overhead Tricep Extension", muscle: "Triceps", secondary: [], equipment: "Dumbbells", difficulty: "beginner", sets: 3, reps: "10-12", rest: "60s", instructions: ["Hold one dumbbell overhead with both hands", "Lower it behind your head by bending elbows", "Extend arms back up, squeezing triceps"] },
    { name: "Close-Grip Push-Ups", muscle: "Triceps", secondary: ["Chest"], equipment: "Bodyweight", difficulty: "intermediate", sets: 3, reps: "10-15", rest: "60s", instructions: ["Push-up position with hands close together", "Lower chest toward hands, elbows tucked", "Push up, focusing on tricep contraction"] },
    { name: "Concentration Curls", muscle: "Biceps", secondary: [], equipment: "Dumbbells", difficulty: "intermediate", sets: 3, reps: "10-12 each", rest: "60s", instructions: ["Sit on bench, elbow braced against inner thigh", "Curl dumbbell up slowly, squeeze at top", "Lower with full control"] },
    { name: "Skull Crushers", muscle: "Triceps", secondary: [], equipment: "Barbell", difficulty: "intermediate", sets: 3, reps: "8-12", rest: "60s", instructions: ["Lie on bench, hold bar above chest with narrow grip", "Lower bar toward forehead by bending elbows", "Extend arms back up without moving upper arms"] },
    { name: "Barbell Curls", muscle: "Biceps", secondary: ["Forearms"], equipment: "Barbell", difficulty: "intermediate", sets: 3, reps: "8-12", rest: "60s", instructions: ["Stand with barbell, underhand grip at shoulder width", "Curl bar up keeping elbows at sides", "Lower slowly, avoid swinging body"] },
  ],
  core: [
    { name: "Plank", muscle: "Core", secondary: ["Shoulders", "Glutes"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "30-60 seconds", rest: "45s", instructions: ["Forearm plank position, body straight from head to heels", "Engage core, don't let hips sag or pike", "Breathe steadily throughout the hold"] },
    { name: "Crunches", muscle: "Abs", secondary: [], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "15-20", rest: "45s", instructions: ["Lie on back, knees bent, hands behind head (don't pull neck!)", "Curl upper body up, engaging abs", "Lower slowly, keeping tension in the core"] },
    { name: "Mountain Climbers", muscle: "Core", secondary: ["Shoulders", "Hip Flexors"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "20 each leg", rest: "45s", instructions: ["Start in high plank position", "Drive one knee toward chest rapidly", "Alternate legs in a running motion", "Keep hips level, core engaged"] },
    { name: "Russian Twists", muscle: "Obliques", secondary: ["Abs"], equipment: "Bodyweight", difficulty: "intermediate", sets: 3, reps: "20 total", rest: "45s", instructions: ["Sit with knees bent, lean back slightly", "Rotate torso side to side, touching floor each side", "For extra difficulty, hold a weight or lift feet off floor"] },
    { name: "Leg Raises", muscle: "Lower Abs", secondary: ["Hip Flexors"], equipment: "Bodyweight", difficulty: "intermediate", sets: 3, reps: "12-15", rest: "45s", instructions: ["Lie flat on back, legs straight", "Raise legs to 90° keeping them straight", "Lower slowly without touching the floor"] },
    { name: "Bicycle Crunches", muscle: "Obliques", secondary: ["Abs"], equipment: "Bodyweight", difficulty: "intermediate", sets: 3, reps: "20 total", rest: "45s", instructions: ["Lie on back, hands behind head", "Bring right elbow to left knee while extending right leg", "Alternate sides in a pedaling motion"] },
    { name: "Dead Bug", muscle: "Core", secondary: ["Hip Flexors"], equipment: "Bodyweight", difficulty: "beginner", sets: 3, reps: "10 each side", rest: "45s", instructions: ["Lie on back, arms extended up, knees bent at 90°", "Extend opposite arm and leg simultaneously", "Return to start, alternate sides", "Keep lower back pressed into floor"] },
    { name: "Hanging Leg Raises", muscle: "Lower Abs", secondary: ["Hip Flexors", "Grip"], equipment: "Bodyweight", difficulty: "advanced", sets: 3, reps: "10-12", rest: "60s", instructions: ["Hang from a pull-up bar with straight arms", "Raise legs to 90° or higher", "Lower slowly, avoid swinging"] },
    { name: "Ab Rollout", muscle: "Core", secondary: ["Lats", "Shoulders"], equipment: "Bodyweight", difficulty: "advanced", sets: 3, reps: "8-12", rest: "60s", instructions: ["Kneel with ab wheel or barbell in front", "Roll forward extending body as far as possible", "Contract abs to pull back to starting position"] },
  ],
};

// Flatten all exercises into a single searchable array
export const allExercises = Object.entries(exercises).flatMap(([group, exList]) =>
  exList.map(ex => ({ ...ex, muscleGroup: group }))
);

// Get exercises by muscle group
export function getExercisesByMuscle(muscleGroup) {
  const key = muscleGroup.toLowerCase();
  return exercises[key] || [];
}

// Get exercises by difficulty
export function getExercisesByDifficulty(difficulty) {
  return allExercises.filter(ex => ex.difficulty === difficulty);
}

// Get exercises by equipment
export function getExercisesByEquipment(equipment) {
  const eq = equipment.toLowerCase();
  return allExercises.filter(ex => ex.equipment.toLowerCase().includes(eq));
}

// Search exercises
export function searchExercises(query) {
  const q = query.toLowerCase();
  return allExercises.filter(ex =>
    ex.name.toLowerCase().includes(q) ||
    ex.muscle.toLowerCase().includes(q) ||
    ex.muscleGroup.toLowerCase().includes(q) ||
    ex.equipment.toLowerCase().includes(q)
  );
}

export default exercises;
