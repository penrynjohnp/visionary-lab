// VideoJob type corresponds to the VideoGenerationJob in the API
export interface VideoJob {
  id: string;
  status: string;
  prompt: string;
  n_variants: number;
  n_seconds: number;
  height: number;
  width: number;
  model?: string;
  progress?: number;
  generations?: Array<{
    id: string;
    prompt?: string;
    status?: string;
  }>;
  createdAt?: number; // Note: mapped from created_at
  updatedAt?: number; // Note: mapped from finished_at in some cases
  created_at?: number;
  finished_at?: number;
  failure_reason?: string;
  has_audio?: boolean;
  is_remix?: boolean;
  remixed_from_video_id?: string;
}

// Interface for the API's VideoGenerationJob
export interface ApiVideoJob {
  id: string;
  status: string;
  prompt: string;
  n_variants: number;
  n_seconds: number;
  height: number;
  width: number;
  model?: string;
  progress?: number;
  created_at?: number;
  finished_at?: number;
  failure_reason?: string;
  has_audio?: boolean;
  is_remix?: boolean;
  remixed_from_video_id?: string;
  generations?: Array<{
    id: string;
    prompt?: string;
    status?: string;
  }>;
}

// Helper function to convert API VideoGenerationJob to VideoJob
export function convertToVideoJob(apiJob: ApiVideoJob): VideoJob {
  return {
    ...apiJob,
    createdAt: apiJob.created_at,
    updatedAt: apiJob.finished_at || apiJob.created_at,
  };
} 