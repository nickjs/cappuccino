/*
 * CPController.j
 * AppKit
 *
 * Created by Ross Boucher.
 * Extended by Nicholas Small.
 * Copyright 2009, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <Foundation/CPObject.j>


var CPControllerDeclaredKeysKey = @"CPControllerDeclaredKeysKey";

@implementation CPController : CPObject
{
    CPArray     _editors;
    CPArray     _declaredKeys;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _editors = [];
        _declaredKeys = [];
    }
    
    return self;
}

- (BOOL)isEditing
{
    return [_editors count] > 0;
}

- (BOOL)commitEditing
{
    while ([_editors count])
        if (![_editors[0] commitEditing])
            return NO;
    
    return YES;
}

- (void)discardEditing
{
    [_editors makeObjectsPerformSelector:@selector(discardEditing)];
}

- (void)objectDidBeginEditing:(id)anEditor
{
    [_editors addObject:anEditor];
}

- (void)objectDidEndEditing:(id)anEditor
{
    [_editors removeObject:anEditor];
    
    [[anEditor bindingObjectForBinding:@"value"] setValueOfDestinationFromBinding];
}

@end

@implementation CPController (CPCoding)

- (void)encodeWithCoder:(CPCoder)aCoder
{
    if ([_declaredKeys count] > 0)
        [aCoder encodeObject:_declaredKeys forKey:CPControllerDeclaredKeysKey];
}

- (id)initWithCoder:(CPCoder)aDecoder
{
    self = [super init];
    
    if (self)
    {
        _editors = [];
        _declaredKeys = [aDecoder decodeObjectForKey:CPControllerDeclaredKeysKey] || [];
    }

    return nil;
}

@end
