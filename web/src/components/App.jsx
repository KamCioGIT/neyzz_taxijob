import React, { useState } from "react";
import "./App.css";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";
import TaxiRides from "./TaxiRides.jsx";

// This will set the NUI to visible if we are
// developing in browser
debugData([
    {
        action: "setVisible",
        data: true,
    },
]);

const ReturnClientDataComp = ({
    data,
}) => (
    <>
        <h5>Returned Data:</h5>
        <pre>
            <code>{JSON.stringify(data, null)}</code>
        </pre>
    </>
);

const App = () => {

    return (
        <div className="nui-wrapper">
            <div className="popup-thing">
                <div>
                    <h1>Courses</h1>
                    <TaxiRides/>
                </div>
            </div>
        </div>
    );
};

export default App;
