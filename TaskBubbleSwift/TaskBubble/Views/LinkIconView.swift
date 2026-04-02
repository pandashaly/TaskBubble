//
//  LinkIconView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 02/04/2026.
//

//
//import SwiftUI
//
//struct LinkIconView: View {
//    let link: String
//
//    func getFaviconURL(for link: String) -> URL? {
//        guard let url = URL(string: link), let host = url.host else { return nil }
//        return URL(string: "https://\(host)/favicon.ico")
//    }
//
//    var body: some View {
//        if let faviconURL = getFaviconURL(for: link) {
//            AsyncImage(url: faviconURL) { image in
//                image.resizable().scaledToFit()
//            } placeholder: {
//                Image(systemName: "safari")
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(.gray)
//            }
//            .frame(width: 24, height: 24)
//        } else {
//            Image(systemName: "safari")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 24, height: 24)
//                .foregroundColor(.gray)
//        }
//    }
//}

//import SwiftUI
//import AppKit
//
//struct LinkIconView: View {
//    let link: String
//    @State private var favicon: NSImage?
//
//    var body: some View {
//        Group {
//            if let favicon = favicon {
//                Image(nsImage: favicon)
//                    .resizable()
//                    .scaledToFit()
//            } else {
//                Image(systemName: "safari")
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(.gray)
//            }
//        }
//        .frame(width: 24, height: 24)
//        .onAppear {
//            fetchFavicon()
//        }
//    }
//
//    private func fetchFavicon() {
//        guard let url = normalizedURL(from: link),
//              let host = url.host,
//              let faviconURL = URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=64")
//        else { return }
//
//        URLSession.shared.dataTask(with: faviconURL) { data, _, _ in
//            if let data = data,
//               let image = NSImage(data: data) {
//                DispatchQueue.main.async {
//                    favicon = image
//                }
//            }
//        }.resume()
//    }
//}

import SwiftUI
import AppKit

struct LinkIconView: View {
    let link: String
    @State private var favicon: NSImage?

    var body: some View {
        Group {
            if let favicon = favicon {
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
        .onAppear {
            fetchFavicon()
        }
    }

    private func fetchFavicon() {
        guard let url = normalizedURL(from: link),
              let host = url.host,
              let faviconURL = URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=64")
        else { return }

        URLSession.shared.dataTask(with: faviconURL) { data, _, _ in
            guard let data = data,
                  let image = NSImage(data: data)
            else { return }

            DispatchQueue.main.async {
                self.favicon = image
            }
        }.resume()
    }
}
