import React, { useState } from 'react';

import MediaPicker from 'react-native-media-picker';
import { Button, Image, StyleSheet, View } from 'react-native';

export default function App() {
  const [image, setImage] = useState<string>();
  const _onPressOpen = () => {
    MediaPicker.launchGallery({
      assetType: 'image',
      limit: 5,
      numberOfColumn: 3,
      showPreview: true,
      maxFileSize: 5,
      maxDuration: 20,
      usedCameraButton: false,
    })
      .then((res) => {
        setImage(res.success[0]?.uri);
      })
      .catch(() => {});
  };

  return (
    <View style={styles.container}>
      <Image
        style={{ width: 160, height: 160, marginBottom: 16 }}
        source={{ uri: image }}
      />
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
