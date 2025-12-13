/**
 * Storage utilities for Cloudflare R2
 * R2 is an S3-compatible object storage service
 */

export interface UploadOptions {
  contentType?: string;
  metadata?: Record<string, string>;
  customMetadata?: Record<string, string>;
}

export interface StorageClient {
  bucket: R2Bucket;
}

/**
 * Create a storage client from an R2 bucket binding
 * @param bucket - The R2 bucket binding from Cloudflare Workers
 */
export function createStorage(bucket: R2Bucket): StorageClient {
  return { bucket };
}

/**
 * Upload a file to R2 storage
 * @param storage - The storage client
 * @param key - The object key (path/filename)
 * @param data - The file data to upload
 * @param options - Upload options
 */
export async function upload(
  storage: StorageClient,
  key: string,
  data: ReadableStream | ArrayBuffer | ArrayBufferView | string | Blob,
  options?: UploadOptions,
): Promise<R2Object> {
  return storage.bucket.put(key, data, {
    httpMetadata: options?.contentType
      ? { contentType: options.contentType }
      : undefined,
    customMetadata: options?.customMetadata,
  });
}

/**
 * Download a file from R2 storage
 * @param storage - The storage client
 * @param key - The object key to download
 */
export async function download(
  storage: StorageClient,
  key: string,
): Promise<R2ObjectBody | null> {
  return storage.bucket.get(key);
}

/**
 * Delete a file from R2 storage
 * @param storage - The storage client
 * @param key - The object key to delete
 */
export async function remove(
  storage: StorageClient,
  key: string,
): Promise<void> {
  await storage.bucket.delete(key);
}

/**
 * List objects in R2 storage
 * @param storage - The storage client
 * @param options - List options (prefix, limit, cursor)
 */
export async function list(
  storage: StorageClient,
  options?: R2ListOptions,
): Promise<R2Objects> {
  return storage.bucket.list(options);
}

/**
 * Check if an object exists in R2 storage
 * @param storage - The storage client
 * @param key - The object key to check
 */
export async function exists(
  storage: StorageClient,
  key: string,
): Promise<boolean> {
  const head = await storage.bucket.head(key);
  return head !== null;
}

/**
 * Get object metadata without downloading the body
 * @param storage - The storage client
 * @param key - The object key
 */
export async function head(
  storage: StorageClient,
  key: string,
): Promise<R2Object | null> {
  return storage.bucket.head(key);
}

/**
 * Generate a public URL for an object (requires public bucket configuration)
 * @param accountId - Your Cloudflare account ID
 * @param bucketName - The R2 bucket name
 * @param key - The object key
 */
export function getPublicUrl(
  accountId: string,
  bucketName: string,
  key: string,
): string {
  return `https://${bucketName}.${accountId}.r2.cloudflarestorage.com/${key}`;
}
