import React, { useState } from "react";
import TaxiRide from "./TaxiRide/TaxiRide";

export default function TaxiRides() {

    const [rides, setRides] = useState(null);

    return (<div className="taxiRides">
        <TaxiRide id={12} name='John Doe' location ="Joshua Road" destination='Vespucci' distance={5230} />
        <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} />
        <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} />
        <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} />
        <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} />
        <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} />
        <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} />
        <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} />
        <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} />
        <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} />
        <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} />
        {/* <TaxiRide id={13} name='John Doe' location="Joshua Road" destination='Vespucci' distance={5230} /> */}

    </div>)
}