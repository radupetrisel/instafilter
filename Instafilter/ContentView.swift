//
//  ContentView.swift
//  Instafilter
//
//  Created by Radu Petrisel on 18.07.2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    private let context = CIContext()
    private let imageSaver = ImageSaver {
        print("Success")
    } errorHandler: {
        print("Oops! \($0.localizedDescription)")
    }
    
    @State private var originalImage: UIImage?
    @State private var outputImage: UIImage?
    
    @State private var isShowingImagePicker = false
    
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    
    @State private var filter: CIFilter = CIFilter.sepiaTone()
    
    @State private var isShowingFilterDialog = false
    
    private var isSaveDisabled: Bool {
        outputImage == nil
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to add image")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture(perform: onImageTapped)
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity) { _ in applyProcessing() }
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change filter", action: onChangeFilterButtonTapped)
                    
                    Spacer()
                    
                    Button("Save", action: onSaveButtonTapped)
                        .disabled(isSaveDisabled)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: originalImage, perform: onOriginalImageChanged(newValue:))
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $originalImage)
            }
            .confirmationDialog("Chose filter", isPresented: $isShowingFilterDialog) {
                Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                Button("Edges") { setFilter(CIFilter.edges()) }
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                Button("Vignette") { setFilter(CIFilter.vignette()) }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    private func onImageTapped() {
        isShowingImagePicker = true
    }
    
    private func onChangeFilterButtonTapped() {
        isShowingFilterDialog = true
    }
    
    private func onSaveButtonTapped() {
        guard let outputImage = outputImage else { return }
        imageSaver.save(image: outputImage)
    }
    
    private func onOriginalImageChanged(newValue: UIImage?) {
        load(image: newValue)
    }
    
    private func load(image: UIImage?) {
        guard let image = image else { return }
        
        let beginImage = CIImage(image: image)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    private func applyProcessing() {
        filter.trySetValue(filterIntensity, forKey: kCIInputIntensityKey)
        filter.trySetValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
        filter.trySetValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        
        guard let ciImage = filter.outputImage else { return }
        
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            outputImage = UIImage(cgImage: cgImage)
            image = Image(uiImage: outputImage!)
        }
    }
    
    private func setFilter(_ filter: CIFilter) {
        self.filter = filter
        
        load(image: originalImage)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

fileprivate extension CIFilter {
    func trySetValue(_ value: Any?, forKey key: String) {
        guard inputKeys.contains(key) else { return }
        
        setValue(value, forKey: key)
    }
}
