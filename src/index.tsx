import { NativeModules, Platform } from 'react-native';

export type MediaPickerOptions = {
  assetType?: 'video' | 'image';
  limit?: number;
  numberOfColumn?: number;
  showPreview?: boolean;
  maxFileSize?: number;
  maxOriginalSize?: number;
  maxDuration?: number;
  usedCameraButton?: boolean;
  maxVideoDuration?: number;
  writeTempFile?: boolean;
  messages?: {
    fileTooLarge?: string;
    noCameraPermissions?: string;
    noAlbumPermission?: string;
    maxSelection?: string;
    ok?: string;
    maxDuration?: string;
    tapHereToChange?: string;
    cancelTitle?: string;
    emptyMessage?: string;
    doneTitle?: string;
  };
};

export type MediaPickerResponse = {
  success: {
    uri: string;
    path: string;
    size: number;
    name: string;
    type: string;
    width?: number;
    height?: number;
    duration?: number;
    origUrl?: string;
    mimeType?: string;
  }[];
  error: number;
};

export type ExportProps = {
  localIdentifier: string;
};

export type ExportVideoResponse = {
  name: string;
  width: string;
  height: number;
  uri: string;
  type: string;
};

type MediaPickerType = {
  launchGallery(options?: MediaPickerOptions): Promise<MediaPickerResponse>;
  exportVideoFromId(options: ExportProps): Promise<ExportVideoResponse>;
};

const { RNMediaPicker } = NativeModules;

const launchGallery = async (options?: MediaPickerOptions) => {
  return RNMediaPicker.launchGallery(options);
};

const exportVideoFromId = async (options: ExportProps) => {
  try {
    if (Platform.OS === 'android') {
      return;
    }
    return RNMediaPicker.exportVideoFromId(options);
  } catch (error) {}
};

export default { launchGallery, exportVideoFromId } as MediaPickerType;
