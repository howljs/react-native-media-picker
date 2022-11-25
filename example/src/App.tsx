import React from 'react';

import MediaPicker from '@howljs/media-picker';
import { Button, StyleSheet, View } from 'react-native';

export default function App() {
  const _onPressOpen = () => {
    MediaPicker.launchGallery()
      .then((res) => {
        console.log(res);
      })
      .catch(() => {});
  };

  return (
    <View style={styles.container}>
      <Button title="Open Picker" onPress={_onPressOpen} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
