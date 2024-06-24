import React from "react";

import './Button.css'

export default function Button({onClick, ...props}) {
    const btnType = props.type == "success" ? "success":
    props.type == "error" ? "error" : "default"
    return (
        <button className={"btn " + btnType} onClick={onClick}>{props.text}</button>
    )
}