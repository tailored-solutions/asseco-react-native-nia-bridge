import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { register } from 'react-native-nia-bridge';

export default function App() {
  const [result] = React.useState<number | undefined>();

  React.useEffect(() => {
    register('TOKEN', 'http://test.com')
      .then(() => console.log('DONE'))
      .catch((err) => console.error(err));
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
