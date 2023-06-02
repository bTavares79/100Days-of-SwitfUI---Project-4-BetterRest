//
//  ContentView.swift
//  BetterRest
//
//  Created by Brian Tavares on 6/2/23.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlret = false
    
    // Compute a time starting at a default of 7am
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    // Compute the bedtime
    var bedTime: String {
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let componets = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (componets.hour ?? 0) * 60 * 60
            let minute = (componets.minute ?? 0) * 60 * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            //alertTitle = "Your idea bedtime is.."
            //alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            return sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            // Calculation went wrong
            //alertTitle = "Error"
            //alertMessage = "Sorry, there was an problem calculating your bedtime"
            
            return "Error"
        }
    }
    
    
    var body: some View {
        NavigationView {
            Form{
                VStack(alignment: .leading, spacing: 0){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }

                VStack(alignment: .leading, spacing: 0){
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    

                }

                VStack(alignment: .leading, spacing: 0){
                    Text("Daily coffe intake")
                        .font(.headline)
                    
                    //Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                    
                    Picker("Number of cups of coffee", selection: $coffeeAmount){
                        ForEach(1..<21){
                            Text($0 == 0 ? "\($0) cup" : "\($0) cups")
                        }
                    }
                }
                
                Spacer()
                
                Text("Your recomended bedtime is:")
                    .font(.headline)
                
                Text("\(bedTime)")
                    .font(.system(size: 36)).bold()
                    .frame(maxWidth: .infinity)

            }
            

            
            
            .navigationTitle("Better Rest")
            //.toolbar{
              //  Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlret){
                Button("OK"){}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
//    func calculateBedTime(){
//        do{
//            let config = MLModelConfiguration()
//            let model = try SleepCalculator(configuration: config)
//            let componets = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
//
//            let hour = (componets.hour ?? 0) * 60 * 60
//            let minute = (componets.minute ?? 0) * 60 * 60
//
//            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
//
//            let sleepTime = wakeUp - prediction.actualSleep
//
//            alertTitle = "Your idea bedtime is.."
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
//
//        } catch {
//            // Calculation went wrong
//            alertTitle = "Error"
//            alertMessage = "Sorry, there was an problem calculating your bedtime"
//
//        }
//        showingAlret = true
//    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
