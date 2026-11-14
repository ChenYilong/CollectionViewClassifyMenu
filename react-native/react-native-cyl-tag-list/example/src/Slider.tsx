import { Pressable, StyleSheet, Text, View } from 'react-native';

const STEPS = [0.25, 0.5, 1, 1.5, 2, 3, 4];

/** Speed steps from 0.25x to 4x (React Native has no built-in slider). */
export default function Slider({ value, onChange }: { value: number; onChange: (v: number) => void }) {
  return (
    <View style={styles.row} accessibilityRole="adjustable" accessibilityLabel="Speed">
      {STEPS.map((step) => (
        <Pressable
          key={step}
          testID={`speed-${step}`}
          accessibilityRole="button"
          accessibilityState={{ selected: step === value }}
          onPress={() => onChange(step)}
          style={[styles.step, step === value && styles.selected]}
        >
          <Text>{step}x</Text>
        </Pressable>
      ))}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: 'row', flexWrap: 'wrap', gap: 6 },
  step: { paddingHorizontal: 8, paddingVertical: 4, borderWidth: 1, borderColor: '#D1D1D6' },
  selected: { backgroundColor: '#E6F8F5', borderColor: '#2AB9A0' },
});
