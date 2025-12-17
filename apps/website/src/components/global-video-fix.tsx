"use client";

import { useEffect } from "react";

export function GlobalVideoFix() {
  useEffect(() => {
    const handleVideo = (node: Node) => {
      if (node instanceof HTMLVideoElement) {
        if (!node.hasAttribute("playsinline")) {
          node.setAttribute("playsinline", "");
        }
      } else if (node instanceof HTMLElement) {
        const videos = node.querySelectorAll("video");
        videos.forEach((video) => {
          if (!video.hasAttribute("playsinline")) {
            video.setAttribute("playsinline", "");
          }
        });
      }
    };

    // Run initially
    document.querySelectorAll("video").forEach((video) => {
      if (!video.hasAttribute("playsinline")) {
        video.setAttribute("playsinline", "");
      }
    });

    // Observe for changes
    const observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        for (const node of mutation.addedNodes) {
          handleVideo(node);
        }
      }
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true,
    });

    return () => observer.disconnect();
  }, []);

  return null;
}
