"""How-to cues, rep ranges and form videos for the alternatives library.

Videos were picked from YouTube search results whose title matches the
exercise (tutorial / proper-form videos). Cues are short coaching points.
Used by generate_alternatives_library.py.
"""

# id -> (video url, rep range, [how-to steps])
DETAILS = {
    # ---- Chest
    'alt_incline_barbell_bench_press': ('https://www.youtube.com/watch?v=jPLdzuHckI8', '6-10', [
        'Set the bench to 30-45° and grip slightly wider than shoulders.',
        'Pin shoulder blades back and down, feet flat.',
        'Lower the bar under control to the upper chest.',
        'Press up toward your collarbone without flaring the elbows.']),
    'alt_barbell_bench_press': ('https://www.youtube.com/watch?v=4Y2ZdHCOXok', '6-10', [
        'Eyes under the bar, shoulder blades squeezed, slight arch.',
        'Elbows about 45-70° from your body.',
        'Touch the lower chest with control, no bounce.',
        'Drive the bar up and slightly back over the shoulders.']),
    'alt_smith_flat_bench_press': ('https://www.youtube.com/watch?v=7FyJdsXeta8', '8-12', [
        'Place the bench so the bar lines up with mid-chest.',
        'Set the safety stops just below chest height.',
        'Grip just outside shoulder width and unhook the bar.',
        'Lower to mid-chest, press up and squeeze.']),
    'alt_cable_chest_press': ('https://www.youtube.com/watch?v=QhxFLOiNN8g', '10-15', [
        'Handles at chest height, back to the machine.',
        'Step forward into a split stance, core braced.',
        'Press forward until arms are straight, hands meeting.',
        'Return slowly until you feel a chest stretch.']),
    'alt_push_up': ('https://www.youtube.com/watch?v=i9sTjhN4Z3M', '8-20', [
        'Hands under shoulders, body straight from head to heels.',
        'Squeeze glutes and brace your core.',
        'Lower your chest to just above the floor, elbows ~45°.',
        'Push the floor away; add a plate on your back to progress.']),
    'alt_db_chest_fly': ('https://www.youtube.com/watch?v=QENKPHhQVi4', '10-15', [
        'Lie flat, dumbbells above chest, slight fixed elbow bend.',
        'Open the arms in a wide arc until a deep chest stretch.',
        'Keep shoulders back on the bench.',
        'Bring the dumbbells together by squeezing the chest.']),
    'alt_mid_cable_crossover': ('https://www.youtube.com/watch?v=taI4XduLpTk', '12-15', [
        'Set pulleys at shoulder height, step forward, split stance.',
        'Slight bend in the elbows, chest up.',
        'Bring the handles together in front of your chest.',
        'Squeeze 1 second, open slowly.']),
    'alt_low_to_high_cable_fly': ('https://www.youtube.com/watch?v=Nx5DnrqA5yc', '12-15', [
        'Set pulleys around knee to mid-thigh height.',
        'Palms forward, slight elbow bend, split stance.',
        'Sweep the handles up to upper-chest height.',
        'Pause at the top, lower under control.']),
    'alt_decline_db_press': ('https://www.youtube.com/watch?v=k9CzXmJcJNw', '8-12', [
        'Sit on a decline bench with the dumbbells on your thighs.',
        'Lie back and hold the weights over your lower chest.',
        'Lower in line with the chest to a full stretch.',
        'Press up and slightly together.']),
    'alt_assisted_chest_dip': ('https://www.youtube.com/watch?v=jsorBuQt7xM', '8-12', [
        'More counterweight = easier. Knees on the pad, hands on bars.',
        'Lean your torso forward to bias the chest.',
        'Lower until shoulders are just below elbows.',
        'Press back up without locking hard.']),
    # ---- Back
    'alt_seated_row_machine': ('https://www.youtube.com/watch?v=TeFo51Q_Nsc', '10-12', [
        'Set the seat so handles are at lower-chest height.',
        'Chest against the pad, back neutral.',
        'Drive the elbows back and squeeze the shoulder blades.',
        'Let the arms extend fully with control.']),
    'alt_barbell_bent_over_row': ('https://www.youtube.com/watch?v=YcK7pyFXmWk', '6-10', [
        'Hinge to about 45°, back flat, knees soft.',
        'Grip just outside the knees.',
        'Row the bar to your lower ribs, no torso swing.',
        'Lower until arms are straight.']),
    'alt_wide_grip_cable_row': ('https://www.youtube.com/watch?v=y7h823PdWIY', '10-12', [
        'Wide bar, overhand grip, feet on the platform.',
        'Sit tall with knees slightly bent.',
        'Pull to the upper abdomen, elbows out ~45°.',
        'Squeeze the upper back, return slowly.']),
    'alt_lat_pulldown': ('https://www.youtube.com/watch?v=RTNmVfnRitA', '8-12', [
        'Thighs under the pad, grip a bit wider than shoulders.',
        'Lean back slightly, chest up.',
        'Pull the bar to the upper chest, elbows down.',
        'Control it up to a full stretch.']),
    'alt_straight_arm_pulldown': ('https://www.youtube.com/watch?v=lJsiuRq7Bts', '12-15', [
        'Pulley above head height, bar or rope.',
        'Slight hip hinge, arms straight with soft elbows.',
        'Sweep the bar down to your thighs using the lats.',
        'Keep elbows straight; raise slowly.']),
    'alt_assisted_pull_up': ('https://www.youtube.com/watch?v=gx0RWT7WbmA', '6-12', [
        'More counterweight = easier. Knees on the pad.',
        'Grip shoulder width or slightly wider.',
        'Pull your chin over the bar, focus on the back squeeze.',
        'Lower all the way to a full hang.']),
    # ---- Traps
    'alt_barbell_shrugs': ('https://www.youtube.com/watch?v=q4x4syK-eXM', '10-15', [
        'Stand tall, bar at the thighs, shoulder-width grip.',
        'Shrug the shoulders straight up toward the ears.',
        'Pause 1 second at the top.',
        'Lower slowly; no rolling. Use straps if grip fails.']),
    'alt_smith_shrugs': ('https://www.youtube.com/watch?v=8ppOGwvaFko', '10-15', [
        'Set the bar at mid-thigh, unhook it.',
        'Torso upright, arms straight.',
        'Shrug straight up without leg drive.',
        'Hold at the top, lower under control.']),
    'alt_cable_kelso_shrug': ('https://www.youtube.com/watch?v=1T_5j7erY2I', '12-15', [
        'Low pulley with a bar, lean the torso slightly forward.',
        'Arms straight; do not bend the elbows.',
        'Pull the shoulder blades back and together.',
        'Hold 1 second, release slowly.']),
    'alt_chest_supported_kelso_shrug': ('https://www.youtube.com/watch?v=zX0c-WIIilk', '12-15', [
        'Chest on an incline bench or row-machine pad.',
        'Let the arms hang straight.',
        'Squeeze the shoulder blades back, no arm pull.',
        'Pause and lower slowly.']),
    # ---- Shoulders
    'alt_lateral_raise_machine': ('https://www.youtube.com/watch?v=uh1UO-ieTYQ', '12-15', [
        'Line your shoulder up with the machine pivot.',
        'Pads on the outside of the arms.',
        'Raise elbows to shoulder height, no shrug.',
        'Lower slowly, keep tension at the bottom.']),
    'alt_lean_away_db_lateral_raise': ('https://www.youtube.com/watch?v=S7Bjyw2ccg0', '12-15', [
        'Hold a pole with one hand and lean away from it.',
        'Dumbbell in the free hand, shoulder down.',
        'Raise to about shoulder height, leading with the elbow.',
        'Lower under control; no swinging.']),
    'alt_cable_y_raise': ('https://www.youtube.com/watch?v=JL1CZxwYo-k', '12-15', [
        'Set the pulleys low, cross the cables.',
        'Step back to keep tension, brace the core.',
        'Raise the arms up and out into a "Y".',
        'Lower slowly.']),
    'alt_reverse_db_fly': ('https://www.youtube.com/watch?v=xcV4SsEIn0I', '12-20', [
        'Hinge forward to about parallel (or chest on a bench).',
        'Slight elbow bend, dumbbells under the shoulders.',
        'Raise the arms out to the sides with the rear delts.',
        'Control the negative; do not swing.']),
    'alt_cable_face_pull': ('https://www.youtube.com/watch?v=wnPX6Fwe-Fg', '12-15', [
        'Rope at upper-chest to face height.',
        'Pull toward your forehead, elbows high and wide.',
        'Rotate the hands back at the end.',
        'Stay upright, light weight, pause each rep.']),
    'alt_cable_rear_delt_row': ('https://www.youtube.com/watch?v=X9HZqdwLG2Y', '12-15', [
        'Rope or handles at chest height.',
        'Pull with elbows high and wide, a bit short of 90°.',
        'Squeeze the rear delts, not the lats.',
        'Return slowly.']),
    # ---- Biceps
    'alt_bayesian_cable_curl': ('https://www.youtube.com/watch?v=aeS38n_Ht6A', '10-15', [
        'Low single handle, face away from the cable.',
        'Step forward so the arm is stretched behind you.',
        'Curl to the shoulder, keep the elbow back.',
        'Lower slowly into the stretch.']),
    'alt_ez_bar_curl': ('https://www.youtube.com/watch?v=SDFZBaJcTsU', '8-12', [
        'Hold the EZ bar palms up, wrists slightly turned in.',
        'Elbows pinned to your sides.',
        'Curl without hip swing.',
        'Lower slowly to full extension.']),
    'alt_cable_bicep_curl': ('https://www.youtube.com/watch?v=pEVXvlVKm80', '10-15', [
        'Low pulley with a bar or rope.',
        'Step back for tension, upper arms still.',
        'Curl up and squeeze the biceps.',
        'Lower under control.']),
    'alt_db_hammer_curl': ('https://www.youtube.com/watch?v=zC3nLlEvin4', '8-12', [
        'Palms facing each other the whole rep.',
        'Elbows fixed at your sides.',
        'Curl without swinging the shoulders.',
        'Lower slowly (~3 seconds).']),
    'alt_cross_body_hammer_curl': ('https://www.youtube.com/watch?v=7MrzVaPM0Uw', '8-12', [
        'Neutral grip, dumbbells at your sides.',
        'Curl one arm across toward the opposite chest.',
        'Keep the wrist straight, squeeze at the top.',
        'Lower and alternate sides.']),
    'alt_preacher_curl_machine': ('https://www.youtube.com/watch?v=jWDZIFhysNc', '10-12', [
        'Set the seat so upper arms lie flat on the pad.',
        'Keep shoulders down and still.',
        'Curl up, squeeze the biceps.',
        'Lower slowly, stop just short of locking.']),
    'alt_ez_bar_preacher_curl': ('https://www.youtube.com/watch?v=e7X6G07KnPI', '8-12', [
        'Armpits snug on the top of the preacher pad.',
        'Grip the EZ bar on the angled part.',
        'Curl up without lifting the elbows.',
        'Lower slowly to almost straight.']),
    # ---- Triceps
    'alt_db_skull_crusher': ('https://www.youtube.com/watch?v=8ncEJDm7Cig', '10-12', [
        'Lie flat, dumbbells over your shoulders, neutral grip.',
        'Bend only at the elbows, lowering beside your head.',
        'Keep the upper arms still.',
        'Extend back up and squeeze.']),
    'alt_close_grip_bench_press': ('https://www.youtube.com/watch?v=VFSEwBszV4g', '6-10', [
        'Grip about shoulder width.',
        'Shoulder blades back, elbows tucked to your sides.',
        'Lower the bar to the bottom of the chest.',
        'Press up by straightening the elbows.']),
    'alt_triceps_dip_machine': ('https://www.youtube.com/watch?v=cidtTZIQ5Kw', '10-12', [
        'Adjust the seat, knees under the pad.',
        'Elbows tucked close to your sides.',
        'Press the handles down until arms are straight.',
        'Return slowly.']),
    'alt_db_triceps_kickback': ('https://www.youtube.com/watch?v=xi806yP2EIE', '12-15', [
        'Hinge forward, back flat, one hand on a bench.',
        'Upper arm parallel to the floor, elbow at 90°.',
        'Extend the forearm back until straight; squeeze.',
        'Lower slowly; only the forearm moves.']),
    'alt_cable_overhead_triceps_extension': ('https://www.youtube.com/watch?v=w3iAESGWK6M', '10-15', [
        'Rope on a low or high pulley, face away.',
        'Step forward, lean slightly, elbows by your head.',
        'Extend the arms forward and up until straight.',
        'Return slowly into the stretch; no elbow flare.']),
    # ---- Forearms
    'alt_db_wrist_curl': ('https://www.youtube.com/watch?v=kEXbp67nJDc', '15-20', [
        'Sit, forearms on your thighs, palms up.',
        'Let the dumbbells roll down to the fingers.',
        'Curl the wrists up as high as possible.',
        'Slow, controlled reps.']),
    'alt_barbell_wrist_curl': ('https://www.youtube.com/watch?v=hSukP162H4M', '15-20', [
        'Forearms on a bench, wrists over the edge, palms up.',
        'Roll the bar out to the fingertips.',
        'Curl it back up by flexing the wrists.',
        'Keep the forearms flat.']),
    'alt_db_reverse_wrist_curl': ('https://www.youtube.com/watch?v=GVz_au4X24M', '15-20', [
        'Forearms on your thighs, palms down.',
        'Use a light weight.',
        'Lift the backs of the hands up.',
        'Lower slowly through the full range.']),
    # ---- Quads
    'alt_hack_squat_machine': ('https://www.youtube.com/watch?v=hglQExHCM9Q', '8-12', [
        'Back and hips flat on the pad, feet shoulder width.',
        'Release the safeties.',
        'Lower until hips are at or below knee level.',
        'Drive through the whole foot; knees track toes.']),
    'alt_smith_squat': ('https://www.youtube.com/watch?v=iAcRGCsG_PY', '8-12', [
        'Bar across the upper back, feet slightly in front.',
        'Grip narrow, elbows down, unhook the bar.',
        'Squeeze down as deep as your form allows.',
        'Stand up through mid-foot.']),
    'alt_bulgarian_split_squat': ('https://www.youtube.com/watch?v=-IpkZv8tZYM', '8-12', [
        'Stand 2-3 feet in front of a bench, back foot on it.',
        'Dumbbells at your sides, torso tall.',
        'Lower the back knee toward the floor.',
        'Drive up through the front heel; switch legs.']),
    'alt_sa_leg_extension': ('https://www.youtube.com/watch?v=nIyw7z2b8xw', '10-15', [
        'Knee lined up with the machine pivot.',
        'Pad on the lower shin of one leg.',
        'Straighten the knee and squeeze the quad 1-2 seconds.',
        'Lower slowly; switch legs.']),
    'alt_heel_elevated_goblet_squat': ('https://www.youtube.com/watch?v=lt9BKstdwdU', '10-15', [
        'Heels on small plates or a wedge.',
        'Hold a dumbbell at your chest.',
        'Squat down with an upright torso, knees forward.',
        'Stand up through the whole foot.']),
    # ---- Adductors
    'alt_cable_hip_adduction': ('https://www.youtube.com/watch?v=SIQrpq6YnT8', '12-15', [
        'Ankle cuff on a low pulley, stand side-on.',
        'Hold the machine for balance, back straight.',
        'Pull the working leg across in front of the other.',
        'Return slowly.']),
    'alt_sumo_goblet_squat': ('https://www.youtube.com/watch?v=R0I3kN0wo9w', '10-15', [
        'Wide stance, toes turned out.',
        'Dumbbell at chest height, elbows under it.',
        'Sit down between your heels, knees out.',
        'Stand up to full hip extension.']),
    'alt_copenhagen_plank': ('https://www.youtube.com/watch?v=5cTh21BfXzI', '20-40 s', [
        'Lie on your side next to a bench.',
        'Top leg on the bench (knee = easier, foot = harder).',
        'Lift the hips so the body is straight.',
        'Hold, then switch sides.']),
    # ---- Glutes / hamstrings
    'alt_barbell_hip_thrust': ('https://www.youtube.com/watch?v=eutQE64svRE', '8-12', [
        'Upper back on a bench, padded bar over the hips.',
        'Feet flat, knees about 90° at the top.',
        'Ribs down, chin tucked, drive the hips up.',
        'Squeeze the glutes 1 second, lower with control.']),
    'alt_smith_hip_thrust': ('https://www.youtube.com/watch?v=qKz4Va7GkUI', '8-12', [
        'Bench behind you, bar over the hip crease.',
        'Feet flat, shins vertical at the top.',
        'Drive through the heels to full hip extension.',
        'Pause, lower slowly.']),
    'alt_hip_thrust_machine': ('https://www.youtube.com/watch?v=UlljOYPM57U', '10-12', [
        'Upper back on the pad, hip pad across the hips.',
        'Feet flat, about shoulder width.',
        'Push through the heels until the torso is level.',
        'Hold 1 second, lower under control.']),
    'alt_glute_bridge': ('https://www.youtube.com/watch?v=wPM8icPu6H8', '12-20', [
        'Lie on your back, knees bent, feet hip width.',
        'Tilt the pelvis so the lower back is flat.',
        'Drive the hips up until knees-hips-shoulders line up.',
        'Squeeze 2-3 s; hold a dumbbell on the hips to load it.']),
    'alt_cable_pull_through': ('https://www.youtube.com/watch?v=fbF4_pn_0xc', '12-15', [
        'Rope on a low pulley, face away, rope between legs.',
        'Hinge back with a flat back, knees soft.',
        'Drive the hips forward to stand tall.',
        'Squeeze the glutes; do not lean back.']),
    'alt_barbell_rdl': ('https://www.youtube.com/watch?v=u87dwyD3EL0', '8-10', [
        'Stand tall, bar at the hips, overhand grip.',
        'Push the hips back, knees soft, back flat.',
        'Slide the bar down the legs to a hamstring stretch.',
        'Drive the hips forward to stand.']),
    'alt_smith_rdl': ('https://www.youtube.com/watch?v=pwGLw2xJCGw', '8-12', [
        'Bar at hip height, stand close to it.',
        'Unhook and hinge back with a neutral spine.',
        'Lower slowly to a deep hamstring stretch.',
        'Squeeze the glutes to stand up.']),
    'alt_single_leg_db_rdl': ('https://www.youtube.com/watch?v=3ed_5PmwLMU', '8-12', [
        'Dumbbell in the hand opposite the standing leg.',
        'Soft knee, hinge forward as the back leg rises.',
        'Keep the hips square to the floor.',
        'Stand back up; switch sides.']),
    'alt_45_back_extension': ('https://www.youtube.com/watch?v=yj1y02fSkNQ', '12-15', [
        'Pad just below the hip crease, feet anchored.',
        'Hinge down with a flat back to a hamstring stretch.',
        'Squeeze the glutes to raise to a straight line.',
        'Do not over-arch at the top; hold a plate to progress.']),
    'alt_lying_leg_curl': ('https://www.youtube.com/watch?v=SbSNUXPRkc8', '10-12', [
        'Lie face down, pad just above the ankles.',
        'Knees just off the bench edge, hips pressed down.',
        'Curl the heels toward the glutes.',
        'Lower slowly; no hip lift.']),
    'alt_swiss_ball_leg_curl': ('https://www.youtube.com/watch?v=XkESHgkTdFw', '10-15', [
        'Lie on your back, heels and calves on the ball.',
        'Lift the hips into a bridge.',
        'Roll the ball toward your glutes by bending the knees.',
        'Keep the hips high as you roll it back.']),
    'alt_cable_glute_kick_back': ('https://www.youtube.com/watch?v=5jJNfIlKTmg', '12-15', [
        'Ankle cuff on a low pulley, face the machine.',
        'Slight hip hinge, core braced, hold the frame.',
        'Kick the leg straight back and up; squeeze.',
        'Return slowly; no lower-back arch.']),
    'alt_glute_kickback_machine': ('https://www.youtube.com/watch?v=gR-3L0Uott8', '12-15', [
        'Adjust the pad to your height.',
        'Brace the core, hips square.',
        'Push the pad back by extending the hip.',
        'Squeeze the glute, return under control.']),
    # ---- Calves
    'alt_seated_calf_raise_machine': ('https://www.youtube.com/watch?v=smyXy_dhXo8', '12-20', [
        'Pad on the thighs just above the knees.',
        'Balls of the feet on the platform.',
        'Lower the heels to a full stretch.',
        'Rise as high as possible, pause 1 second.']),
    'alt_smith_calf_raise': ('https://www.youtube.com/watch?v=cJs1Q4IuPdY', '10-15', [
        'Bar on your traps, balls of feet on a stable plate.',
        'Do not use a step box — it can tip.',
        'Lower the heels slowly.',
        'Rise up high and pause.']),
    'alt_sa_db_calf_raise': ('https://www.youtube.com/watch?v=1D7s-VyLq0Y', '10-15', [
        'One foot on a step edge, dumbbell in the same hand.',
        'Other hand on a wall for balance.',
        'Lower the heel below the step.',
        'Rise up slowly; switch legs.']),
    # ---- Core / mobility
    'alt_thread_the_needle': ('https://www.youtube.com/watch?v=oAQ_qycUj5o', '6-8 / side', [
        'Start on all fours, hips level.',
        'Slide one arm under your body, palm up.',
        'Lower that shoulder and your head to the floor.',
        'Hold a breath or two, reach up, switch sides.']),
    'alt_plank': ('https://www.youtube.com/watch?v=BQu26ABuVS0', '30-60 s', [
        'Elbows under the shoulders.',
        'Body straight from head to heels.',
        'Brace as if for a punch; squeeze glutes.',
        'Breathe; stop when the hips sag.']),
    'alt_side_plank': ('https://www.youtube.com/watch?v=0M-erHBl48U', '20-45 s / side', [
        'Elbow under the shoulder, feet stacked.',
        'Lift the hips into a straight line.',
        'Do not let the hips drop or rotate.',
        'Hold, then switch sides; knees down = easier.']),
}
