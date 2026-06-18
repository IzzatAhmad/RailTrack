/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.railtrack.system.model;

/**
 *
 * @author izzat
 */
public class MenuItem {
 
    private int     id;
    private String  itemKey;
    private String  label;
    private String  icon;
    private String  iconColor;
    private String  url;
    private int     sortOrder;
    private boolean enabled;
 
    // ── Constructors ─────────────────────────────────────────────
    public MenuItem() {}
 
    public MenuItem(int id, String itemKey, String label,
                    String icon, String iconColor,
                    String url, int sortOrder, boolean enabled) {
        this.id        = id;
        this.itemKey   = itemKey;
        this.label     = label;
        this.icon      = icon;
        this.iconColor = iconColor;
        this.url       = url;
        this.sortOrder = sortOrder;
        this.enabled   = enabled;
    }
 
    // ── Getters / Setters ─────────────────────────────────────────
    public int     getId()        { return id; }
    public void    setId(int id)  { this.id = id; }
 
    public String  getItemKey()             { return itemKey; }
    public void    setItemKey(String k)     { this.itemKey = k; }
 
    public String  getLabel()               { return label; }
    public void    setLabel(String l)       { this.label = l; }
 
    public String  getIcon()                { return icon; }
    public void    setIcon(String i)        { this.icon = i; }
 
    public String  getIconColor()           { return iconColor; }
    public void    setIconColor(String c)   { this.iconColor = c; }
 
    public String  getUrl()                 { return url; }
    public void    setUrl(String u)         { this.url = u; }
 
    public int     getSortOrder()           { return sortOrder; }
    public void    setSortOrder(int s)      { this.sortOrder = s; }
 
    public boolean isEnabled()              { return enabled; }
    public void    setEnabled(boolean e)    { this.enabled = e; }
}
 