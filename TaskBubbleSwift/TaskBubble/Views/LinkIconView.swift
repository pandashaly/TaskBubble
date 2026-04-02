//
//  LinkIconView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 02/04/2026.
//

import AppKit
import SwiftUI

struct LinkIconView: View {
    let link: String
    @State private var favicon: NSImage?

    var body: some View {
        Group {
            if let favicon {
                Image(nsImage: favicon)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "safari")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .padding(2)
            }
        }
        .frame(width: 24, height: 24)
        .task(id: link) {
            await loadFavicon()
        }
    }

    private func loadFavicon() async {
        favicon = nil
        guard let url = normalizedURL(from: link), let host = url.host else { return }

        var components = URLComponents(string: "https://www.google.com/s2/favicons")
        components?.queryItems = [
            URLQueryItem(name: "domain", value: host),
            URLQueryItem(name: "sz", value: "64"),
        ]
        guard let faviconURL = components?.url else { return }

        do {
            let (data, response) = try await URLSession.shared.data(from: faviconURL)
            guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else { return }
            guard let image = NSImage(data: data) else { return }
            favicon = image
        } catch {
            // Network blocked or request failed; keep placeholder.
        }
    }
}
