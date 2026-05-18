const { GoogleGenAI } = require('@google/genai');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');

const geminiApiKey = defineSecret('GEMINI_API_KEY');
const defaultModel = 'gemini-2.5-flash';

function getClient() {
  return new GoogleGenAI({ apiKey: geminiApiKey.value() });
}

function asString(value, field, { max = 50000, required = true } = {}) {
  if (value == null || value == '') {
    if (!required) return null;
    throw new HttpsError('invalid-argument', `${field} is required.`);
  }
  if (typeof value != 'string') {
    throw new HttpsError('invalid-argument', `${field} must be a string.`);
  }
  const trimmed = value.trim();
  if (!trimmed && required) {
    throw new HttpsError('invalid-argument', `${field} is required.`);
  }
  if (trimmed.length > max) {
    throw new HttpsError(
      'invalid-argument',
      `${field} exceeds the allowed length.`,
    );
  }
  return trimmed;
}

function asInteger(value, field, { min = 1, max = 10, fallback } = {}) {
  if (value == null) return fallback;
  if (typeof value != 'number' || !Number.isInteger(value)) {
    throw new HttpsError('invalid-argument', `${field} must be an integer.`);
  }
  if (value < min || value > max) {
    throw new HttpsError(
      'invalid-argument',
      `${field} must be between ${min} and ${max}.`,
    );
  }
  return value;
}

function asTools(value) {
  if (!Array.isArray(value)) {
    throw new HttpsError('invalid-argument', 'tools must be an array.');
  }
  return value;
}

function resolveModel(requestedModel) {
  if (requestedModel == null || requestedModel === '') return defaultModel;
  if (typeof requestedModel != 'string') {
    throw new HttpsError('invalid-argument', 'model must be a string.');
  }
  const model = requestedModel.trim();
  if (!/^[a-zA-Z0-9._-]{3,64}$/.test(model)) {
    throw new HttpsError('invalid-argument', 'model contains invalid characters.');
  }
  return model;
}

function normalizeError(error) {
  if (error instanceof HttpsError) return error;
  const message =
    typeof error?.message === 'string' && error.message.trim().length > 0
      ? error.message.trim()
      : 'Gemini request failed.';
  return new HttpsError('internal', message);
}

function extractText(response) {
  return typeof response?.text === 'string' ? response.text : '';
}

exports.geminiGenerateText = onCall(
  {
    secrets: [geminiApiKey],
    timeoutSeconds: 60,
    memory: '512MiB',
  },
  async (request) => {
    try {
      const prompt = asString(request.data?.prompt, 'prompt');
      const model = resolveModel(request.data?.model);
      const ai = getClient();
      const response = await ai.models.generateContent({
        model,
        contents: prompt,
        config: {
          temperature: 0.7,
          maxOutputTokens: 2048,
        },
      });
      return { text: extractText(response), model };
    } catch (error) {
      throw normalizeError(error);
    }
  },
);

exports.geminiAnalyzeImage = onCall(
  {
    secrets: [geminiApiKey],
    timeoutSeconds: 120,
    memory: '1GiB',
  },
  async (request) => {
    try {
      const prompt = asString(request.data?.prompt, 'prompt');
      const model = resolveModel(request.data?.model);
      const mimeType = asString(request.data?.mimeType, 'mimeType', {
        max: 120,
      });
      const data = asString(request.data?.data, 'data', {
        max: 12 * 1024 * 1024,
      });
      const ai = getClient();
      const response = await ai.models.generateContent({
        model,
        contents: [
          {
            role: 'user',
            parts: [
              { text: prompt },
              {
                inlineData: {
                  mimeType,
                  data,
                },
              },
            ],
          },
        ],
        config: {
          temperature: 0.2,
          maxOutputTokens: 2048,
        },
      });
      return { text: extractText(response), model };
    } catch (error) {
      throw normalizeError(error);
    }
  },
);

exports.geminiRunAgent = onCall(
  {
    secrets: [geminiApiKey],
    timeoutSeconds: 120,
    memory: '1GiB',
  },
  async (request) => {
    try {
      const prompt = asString(request.data?.prompt, 'prompt');
      const model = resolveModel(request.data?.model);
      const tools = asTools(request.data?.tools);
      const ai = getClient();
      asInteger(request.data?.maxIterations, 'maxIterations', {
        min: 1,
        max: 5,
        fallback: 3,
      });
      const response = await ai.models.generateContent({
        model,
        contents: prompt,
        config: {
          tools,
          temperature: 0.3,
          maxOutputTokens: 1024,
        },
      });
      const functionCalls = response.functionCalls ?? [];

      return {
        text: extractText(response).trim(),
        calls: functionCalls.map((functionCall) => ({
          name: functionCall.name,
          args: functionCall.args ?? {},
        })),
        model,
      };
    } catch (error) {
      throw normalizeError(error);
    }
  },
);
